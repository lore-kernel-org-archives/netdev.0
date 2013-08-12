From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 3.11] genetlink: fix family dump race
Date: Mon, 12 Aug 2013 10:54:57 +0200
Message-ID: <1376297697.11514.8.camel@jlt4.sipsolutions.net>
References: <1375879163-2116-1-git-send-email-johannes@sipsolutions.net>
	 <20130811.212942.413012801159758438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch, andrei.otcheretianski@intel.com,
	ilan.peer@intel.com, stable@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50368 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754527Ab3HLIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 04:55:15 -0400
In-Reply-To: <20130811.212942.413012801159758438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-11 at 21:29 -0700, David Miller wrote:

> > BUG: unable to handle kernel paging request at f8467360
> > IP: [<c14c56bb>] ctrl_dumpfamily+0x6b/0xe0
> > EIP: 0060:[<c14c56bb>] EFLAGS: 00210297 CPU: 2
> > EIP is at ctrl_dumpfamily+0x6b/0xe0
> > EAX: f8467378 EBX: f8467340 ECX: 00000000 EDX: ec1610c4
> > ESI: 00000001 EDI: c2077cc0 EBP: c46c3c00 ESP: c46c3bd4
> >  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > CR0: 80050033 CR2: f8467360 CR3: 26e54000 CR4: 001407d0
> > DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> > DR6: ffff0ff0 DR7: 00000400
> > Process wpa_supplicant (pid: 20081, ti=c46c2000 task=c44640b0 task.ti=c46c2000)
> > Call Trace:
> >  [<c14c20bc>] netlink_dump+0x5c/0x200
> >  [<c14c3450>] __netlink_dump_start+0x140/0x160
> >  [<c14c5172>] genl_rcv_msg+0x102/0x270
> >  [<c14c4b5e>] netlink_rcv_skb+0x8e/0xb0
> >  [<c14c505c>] genl_rcv+0x1c/0x30
> >  [<c14c456b>] netlink_unicast+0x17b/0x1c0
> >  [<c14c47d4>] netlink_sendmsg+0x224/0x370
> >  [<c1485adf>] sock_sendmsg+0xff/0x120
> 
> I completely agree with your analysis that we need locking here, but
> the crash OOPS backtrace doesn't make any sense to me.
> 
> The bug should trigger when we enter the dump continuation path, which
> would look like:
> 
>         ctrl_dumpfamily()
>         netlink_dump()
>         netlink_recvmsg()
>         ...
> 
> Since this is the only way we get into ctrl_dumpfamily() without
> holding genl_lock().
> 
> But in your trace we're going through genl_rcv() which means this is
> the first call of the dump, and genl_rcv() takes the necessary locks.

Huh, yes, I only looked at the crash info as far as I needed to see that
it was crashing at accessing "rt->netnsok" with a not totally invalid
pointer "rt" (it's in EBX) and then went from the code ...

Ok, I see what's going on here. The bug was reported to me against an
old kernel (3.4.47!) and that actually did an unlock in genl_rcv_msg()
before calling netlink_dump_start():

        if (nlh->nlmsg_flags & NLM_F_DUMP) {
                if (ops->dumpit == NULL)
                        return -EOPNOTSUPP;

                genl_unlock();
                {
                        struct netlink_dump_control c = {
                                .dump = ops->dumpit,
                                .done = ops->done,
                        };
                        err = netlink_dump_start(net->genl_sock, skb,
nlh, &c);
                }
                genl_lock();
                return err;
        }

That was changed in Pravin's commit
def3117493eafd9dfa1f809d861e0031b2cc8a07
"genl: Allow concurrent genl callbacks." very recently - I'm not sure if
that was intentional, it's not described in the commit log.


I think for the current code the fix would still be correct, I can
change the commit message if you like. For backporting, we'll have to
check which tree has Pravin's change and which doesn't and change this
accordingly, I suppose.

johannes
