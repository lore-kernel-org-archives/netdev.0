From: "Wan, Kaike" <kaike.wan@intel.com>
Subject: RE: net: GPF in __netlink_ns_capable
Date: Wed, 20 Jan 2016 14:35:59 +0000
Message-ID: <3F128C9216C9B84BB6ED23EF16290AFB185A437D@CRSMSX101.amr.corp.intel.com>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
	<CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
	<20160118092047.GA30682@gondor.apana.org.au>
	<878u3m7i5q.fsf@x220.int.ebiederm.org> <87vb6q63co.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	"Nicolas Dichtel" <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	"Alexander Potapenko" <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	"Eric Dumazet" <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"Fleck, John" <john.fleck@intel.com>,
	"Weiny, Ira" <ira.weiny@intel.com>,
	"Doug Ledford" <dledford@redhat.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vb6q63co.fsf@x220.int.ebiederm.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From the code (netlink_dump() in net/netlink/af_netlink.c), it shows that a skb is allocated without initializing the skb->cb[] field, which will cause oops if netlink_capable() is called with the duplicate skb. This will happen if the netlink_dump_start() path is followed (in ibnl_rcv_msg() in drivers/infiniband/core/netlink.c). However, for the IB netlink local service, we handle only request RDMA_NL_LS_OP_SET_TIMEOUT and response to RDMA_NL_LS_OP_RESOLVE, which directly call the registered dump function (ib_nl_handle_resolve_resp() and ib_nl_handle_resolve_resp()). See the following snippet:

/*
			 * For response or local service set_timeout request,
			 * there is no need to use netlink_dump_start.
			 */
			if (!(nlh->nlmsg_flags & NLM_F_REQUEST) ||
			    (index == RDMA_NL_LS &&
			     op == RDMA_NL_LS_OP_SET_TIMEOUT)) {
				struct netlink_callback cb = {
					.skb = skb,
					.nlh = nlh,
					.dump = client->cb_table[op].dump,
					.module = client->cb_table[op].module,
				};

				return cb.dump(skb, &cb);
			}

I have just tested the code with rping and ibacm with Doug's k.o/for-4.3 and k.o/for-4.5 branches:

git://github.com/dledford/linux.git

root@phifs011 wfr-ibacm]# rping -c -v -d -C 1 -a 10.228.216.26
count 1
created cm_id 0x24065d0
cma_event type RDMA_CM_EVENT_ADDR_RESOLVED cma_id 0x24065d0 (parent)
cma_event type RDMA_CM_EVENT_ROUTE_RESOLVED cma_id 0x24065d0 (parent)
rdma_resolve_addr - rdma_resolve_route successful
created pd 0x240b640
created channel 0x2406c30
created cq 0x2406290
created qp 0x2406c50
rping_setup_buffers called on cb 0x2403010
allocated & registered buffers...
cq_thread started.
cma_event type RDMA_CM_EVENT_ESTABLISHED cma_id 0x24065d0 (parent)
ESTABLISHED
rmda_connect successful
RDMA addr 2406da0 rkey 252600 len 64
send completion
recv completion
RDMA addr 2406d10 rkey 242500 len 64
send completion
recv completion
ping data: rdma-ping-0: ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqr
cma_event type RDMA_CM_EVENT_DISCONNECTED cma_id 0x24065d0 (parent)
client DISCONNECT EVENT...
rping_free_buffers called on cb 0x2403010
destroy cm_id 0x24065d0
[root@phifs011 wfr-ibacm]#
[root@phifs011 wfr-ibacm]#
[root@phifs011 wfr-ibacm]# uname -a
Linux phifs011 4.3.0-rc3+ #2 SMP Thu Oct 29 09:40:20 EDT 2015 x86_64 x86_64 x86_64 GNU/Linux


[root@phifs011 ~]# rping -c -v -d -C 1 -a 10.228.216.26
count 1
created cm_id 0xTCP: request_sock_TCP: Possible SYN flooding on port 6125. Sending cookies.  Check SNMP counters.
15fb5d0
cma_event type RDMA_CM_EVENT_ADDR_RESOLVED cma_id 0x15fb5d0 (parent)
cma_event type RDMA_CM_EVENT_ROUTE_RESOLVED cma_id 0x15fb5d0 (parent)
rdma_resolve_addr - rdma_resolve_route successful
created pd 0x1600640
created channel 0x15fbc30
created cq 0x15fb290
created qp 0x15fbc50
rping_setup_buffers called on cb 0x15f8010
allocated & registered buffers...
cq_thread started.
cma_event type RDMA_CM_EVENT_ESTABLISHED cma_id 0x15fb5d0 (parent)
ESTABLISHED
rmda_connect successful
RDMA addr 15fbda0 rkey 50600 len 64
send completion
recv completion
RDMA addr 15fbd10 rkey 40500 len 64
send completion
recv completion
ping data: rdma-ping-0: ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqr
cma_event type RDMA_CM_EVENT_DISCONNECTED cma_id 0x15fb5d0 (parent)
client DISCONNECT EVENT...
rping_free_buffers called on cb 0x15f8010
destroy cm_id 0x15fb5d0
[root@phifs011 ~]# uname -a
Linux phifs011 4.4.0-rc6+ #1 SMP Wed Jan 20 10:03:27 EST 2016 x86_64 x86_64 x86_64 GNU/Linux
[root@phifs011 ~]# cat /var/log/ibacm.log |grep _nl_
1453303250.873: acm_nl_receive: nlmsg: len 152 type 0x1000 flags 0x1 seq 1 pid 0
1453303250.873: acm_nl_process_resolve: path use 0x2
1453303250.873: acm_nl_parse_path_attr: service_id 0x1061c06
1453303250.873: acm_nl_parse_path_attr: path dgid fe80::11:7500:78:ad92
1453303250.873: acm_nl_parse_path_attr: path sgid fe80::11:7500:78:a424
1453303250.873: acm_nl_parse_path_attr: pkey 0xffff
1453303250.873: acm_nl_parse_path_attr: qos_class 0x0
1453303250.873: acm_nl_send: acm status success
1453303388.175: acm_nl_receive: nlmsg: len 152 type 0x1000 flags 0x1 seq 2 pid 0
1453303388.175: acm_nl_process_resolve: path use 0x2
1453303388.175: acm_nl_parse_path_attr: service_id 0x1061c06
1453303388.175: acm_nl_parse_path_attr: path dgid fe80::11:7500:78:ad92
1453303388.175: acm_nl_parse_path_attr: path sgid fe80::11:7500:78:a424
1453303388.175: acm_nl_parse_path_attr: pkey 0xffff
1453303388.175: acm_nl_parse_path_attr: qos_class 0x0
1453303388.175: acm_nl_send: acm status success

How could this cause crash?

Kaike

> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm@xmission.com]
> Sent: Monday, January 18, 2016 3:27 PM
> To: Herbert Xu
> Cc: Richard Weinberger; David S. Miller; Thomas Graf; Daniel Borkmann;
> Ken-ichirou MATSUZAWA; Nicolas Dichtel; Florian Westphal; netdev; LKML;
> syzkaller; Kostya Serebryany; Alexander Potapenko; Sasha Levin; Eric
> Dumazet; Dmitry Vyukov; Wan, Kaike; Fleck, John; Weiny, Ira; Doug Ledford
> Subject: Re: net: GPF in __netlink_ns_capable
> 
> 
> Apparently we have missed entirely the folks who added this chunk of this
> code to the kernel on this thread, so adding them now.
> 
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > Herbert Xu <herbert@gondor.apana.org.au> writes:
> >
> >> On Sat, Jan 16, 2016 at 01:08:33AM +0100, Richard Weinberger wrote:
> >>> On Fri, Jan 15, 2016 at 11:31 PM, Dmitry Vyukov <dvyukov@google.com>
> wrote:
> >>> > Call Trace:
> >>> >  [<     inline     >] netlink_ns_capable net/netlink/af_netlink.c:1417
> >>> >  [<ffffffff8529c0a5>] netlink_capable+0x25/0x30
> >>> > net/netlink/af_netlink.c:1432
> >>>
> >>> Hmm, we're crashing because NETLINK_CB(skb).sk is NULL.
> >>> netlink_dump() creates a new skb without a netlink control block,
> >>> but infiniband's dump functions use netlink_capable() which needs a
> >>> valid NETLINK_CB(skb).sk.
> >>>
> >>> What about something like that?
> >>
> >> No you can't do it here as netlink_unicast also calls this and for
> >> that case you'd be overwriting the original sending user-space socket
> >> with the kernel socket.
> >>
> >> I'm adding Eric Bierderman as he wrote some of the code in question.
> >
> > *Scratches my head*
> >
> > I think I am just going to recommend removing that bit of code from
> > the infiniband stack.
> >
> > There are several things very wrong here.
> >
> > First netlinnk_capable and it's ilk are for the very specific purpose
> > of handling backwards compatibility as a truly clean solution of
> > checking at open or connect time would break existing applications.
> > ib_nl_handle_resolv_resp is new code.  So it can almost certainly do
> > something cleaner.
> >
> > netlink_capable is very much not for filtering netlink dumps, but for
> > filtering the queries themselves.  So it appears the capability check
> > is very much in the wrong place.
> >
> > All of this is newish code and apparently never even tested as this
> > code should have failed this way for everyone.  So since the code does
> > not work not apparently has never worked, it is probably easiest just
> > to remove the problematic code (AKA revert), and start fresh and not
> > something that requires backwards compatibility hacks from day one.
> >
> > By new I mean code that came in through the commit below.
> >
> > commit 2ca546b92a024d07adedd15b4c262b1c2c0786ec
> > Author: Kaike Wan <kaike.wan@intel.com>
> > Date:   Fri Aug 14 08:52:09 2015 -0400
> >
> >     IB/sa: Route SA pathrecord query through netlink
> >
> >     This patch routes a SA pathrecord query to netlink first and processes the
> >     response appropriately. If a failure is returned, the request will be sent
> >     through IB. The decision whether to route the request to netlink first is
> >     determined by the presence of a listener for the local service netlink
> >     multicast group. If the user-space local service netlink multicast group
> >     listener is not present, the request will be sent through IB, just like
> >     what is currently being done.
> >
> >     Signed-off-by: Kaike Wan <kaike.wan@intel.com>
> >     Signed-off-by: John Fleck <john.fleck@intel.com>
> >     Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> >     Signed-off-by: Doug Ledford <dledford@redhat.com>
> 
> What was this code trying to do with netlink_capable besides oops the kernel?
> 
> Eric
