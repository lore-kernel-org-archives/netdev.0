From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Wed, 29 Mar 2006 20:44:09 -0800 (PST)
Message-ID: <20060329.204409.109404254.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, bb@kernelpanic.ru,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, herbert@gondor.apana.org.au
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: jesse.brandeburg@intel.com
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Wed, 29 Mar 2006 18:53:57 -0800

> To do this we have code like so in e1000_tso:
> 2529         if (skb_shinfo(skb)->tso_size) {
> 2530                 if (skb_header_cloned(skb)) {
> 2531                         err = pskb_expand_head(skb, 0, 0,
> GFP_ATOMIC);
> 2532                         if (err)
> 2533                                 return err;
> 2534                 }

I was wondering if that call could somehow mess up the
sk->sk_forward_alloc value later on.

But it can't, sk_forward_alloc is modified based upon the
skb->truesize value, but pskb_expand_head() does not change that.

So the things left to check in the generic networking are the
skb_shinfo() contents and ->dataref handling.

I considered whether pskb_expand_head() could corrupt the TSO
information in skb_shinfo().  But that's clearly not the case because
pskb_expand_head() explicitly copies it over:

	memcpy(data + size, skb->end, sizeof(struct skb_shared_info));

And skb->end is set appropriately:

	skb->end      = data + size;

because skb_shinfo() is:

#define skb_shinfo(SKB)		((struct skb_shared_info *)((SKB)->end))

The only skb_shared_info that has to be explicitly setup is the
dataref, and pskb_expand_head() does that:

	atomic_set(&skb_shinfo(skb)->dataref, 1);

So that all checks out.

I wonder if something funky is going on wrt. the skb_release_data()
that pskb_expand_head() does.  We have that SKB_DATAREF_SHIFT thingy,
which will trigger in this case.

	if (!skb->cloned ||
	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
			       &skb_shinfo(skb)->dataref)) {

When we enqueue a new TCP frame we do skb_header_release() which goes:

	skb->nohdr = 1;
	atomic_add(1 << SKB_DATAREF_SHIFT, &skb_shinfo(skb)->dataref);

Presumably the dataref is "1" already when we get here and do this.
We will clone, the clone will set ->nohdr to 0 and will increment the
dataref.

So at this point the dataref should be:

   1 /* initial reference */
 + (1 << SKB_DATAREF_SHIFT) /* from skb_header_release() */
 + 1 /* from skb_clone */

This all works out because when the clone is freed up, skb->nohdr will
be zero, so we will subtract "1" from dataref.  Later when the ACK
arrives we'll free up the non-clone and this will have skb->nohdr set
to "1" and thus we'll subtract

	(1 << SKB_DATAREF_SHIFT) + 1

from dataref, as per skb_release_data().

Although maybe relevant here, I just noticed that __skb_linearize()
does not clear skb->nohdr.  I bet that will cause a bunch of trouble
if the original SKB had skb->nohdr set, but I cannot see how that
can occur, we only send clones out to the device and those have
skb->nohdr clear (Herbert, double check this for me please).

Luckily that thing is used rarely.  Only in the dev_queue_xmit()
path when the SKB has been configured in such a way that the
transmitting device does not support so it should not be relevant
here.  Also I note that __skb_linearize() is not used at all
outside of net/core/dev.c, so we should mark it static some point
soon.  In fact we should do that while fixing this fringe "nohdr"
bug in __skb_linearize().

All the other dataref accesses look safe.

Herbert do you see any holes here?


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
