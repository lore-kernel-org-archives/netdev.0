From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Fri, 29 Jan 2010 03:42:45 -0500
Message-ID: <1264754565.2793.405.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
	 <1264720891.2793.205.camel@tonnant>  <1264727492.2793.207.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264727492.2793.207.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

So I did some poking (still trying to figure out netfilter a little
internally) and looked over the handling of connection tracking. The
oops reports I have been getting generally lie in __nf_conntrack_find,
specifically within a hlist iterator that looks up the information for
the current connection in a per-net namespace hashtable (under RCU, it's
been locked already by the time we get in here). Here's the piece:

        hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
hnnode) {
                if (nf_ct_tuple_equal(tuple, &h->tuple)) {
                        NF_CT_STAT_INC(net, found);
                        local_bh_enable();
                        return h;
                }
                NF_CT_STAT_INC(net, searched);
        }

Instrumenting the kernel at the moment and then setting up more of a
debugging environment to poke at what goes wrong here. Perhaps there's
some broken RCU assumption - I just spent the last few hours reading
over netfilter source and Paul's RCU docs again to brush up.

Perhaps you netdev folks can let me know if there's a handy netfilter
debugging guide somewhere.

Jon.


