From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Tue, 19 Oct 2004 18:51:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098226288.23628.6.camel@krustophenia.net>
References: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au>
	 <1098222676.23367.18.camel@krustophenia.net>
	 <20041019215401.GA16427@gondor.apana.org.au>
	 <1098223857.23367.35.camel@krustophenia.net>
	 <20041019153308.488d34c1.davem@davemloft.net>
	 <1098225729.23628.2.camel@krustophenia.net>
	 <20041019154249.6afcaaad.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vda@port.imtp.ilyichevsk.odessa.ua,
        Linux Network Development <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041019154249.6afcaaad.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-10-19 at 18:42, David S. Miller wrote:
> AIUI the only valid reason to use preempt_disable/enable is in
> > the case of per-CPU data.  This is not "real" per-CPU data, it's a
> > performance hack.  Therefore it would be incorrect to add the preemption
> > protection, the fix is not to manually call do_softirq but to let the
> > softirq run by the normal mechanism.
> > 
> > Am I missing something?
> 
> In code paths where netif_rx_ni() is called, there is not a softirq return
> path check, which is why it is checked here.
> 
> Theoretically, if you remove the check, softirq processing can be deferred
> indefinitely.
> 
> What I'm saying, therefore, is that netif_rx_ni() it not just a performance
> hack, it is necessary for correctness as well.
> 

OK, thanks for clarifying.  The correct patch is therefore:

--- include/linux/netdevice.h~	2004-10-19 18:50:18.000000000 -0400
+++ include/linux/netdevice.h	2004-10-19 18:51:01.000000000 -0400
@@ -696,9 +696,11 @@
  */
 static inline int netif_rx_ni(struct sk_buff *skb)
 {
+       preempt_disable();
        int err = netif_rx(skb);
        if (softirq_pending(smp_processor_id()))
                do_softirq();
+       preempt_enable();
        return err;
 }
 
Lee
