From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC cdc_ncm] introducing allocation mode
Date: Tue, 2 Jun 2015 07:46:18 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506020651430.7210@localhost.localdomain>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain> <20150601005917.GB5320@kroah.com> <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain> <1433144906.1557.2.camel@suse.com> <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
 <1433155778.1884.12.camel@suse.de> <alpine.LNX.2.20.1506011319330.4326@localhost.localdomain> <1433160022.1884.18.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433160022.1884.18.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

First of all - hello everyone, and thank you for the help.
I am here to learn something - so I am happy about having the opportunity of 
discussing this with you. I am a newbie in development, sure.

On Mon, 1 Jun 2015, Oliver Neukum wrote:

==Date: Mon, 1 Jun 2015 14:00:22
==From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
==Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
==
==On Mon, 2015-06-01 at 13:41 +0200, Enrico Mioso wrote:
==> Thank you Oliver, thank you all for reading this thread and the attention.
==> For a more detailed discussion and how we got here, you might google for the 
==> thread:
==> "Is this 32-bit NCM?"
==> and
==> "Is this 32-bit NCM?y" (follow up).
==> Where the "y" letter comes from a mistake of mine.
==
==Having read them it looks like the issues of padding and
==sequence numbers are open.
==
No - we tested the sequence number thing - and it didn't influence the device 
behaviour.
We also tested the padding if I am not wrong: with the same results. Bjorn Mork 
did a great job in making the cdc_ncm driver more flexible and rendering 
debugging so much easier. I thank him.

==> The specification does only mandate the position of the NTH (header). The rest 
==> can be in any order and position in general. This will work with most devices: 
==> except, of course, those from Huawei.
==
==Indeed. And a redesign for crap devices looks like
==a bad idea.
==
==> Our aggregate looks something like this from my perspective (anyone correct me 
==> in case):
==> NTH: header
==> NDP: contains indexing informations
==> ethernet packet 1
==> ethernet packet 2
==> ...
==> ethernet packet n;
==> 
==> While it should look like:
==> NTH: header
==> ethernet packet 1
==> ethernet packet 2
==> ...
==> ethernet packet n;
==> NDP: contains indexing informations
==> 
==> but, when introducing such a change: you might break other devices now working. 
==> Infact, clearly there are multiple vendors producing NCM device, as you might 
==> also see by looking at the dirver's comments.
==> So in general, we should be able to dynamically change the way in which the 
==> driver order things in the package.
==> and that's why I initially proposed the "redesign".
==
==OK, so the NDP needs to be at the end. However in the old thread
==you state that this requires the NDP to be built between the
==final aggregate and physically transmitting. I think this is a false
==choice. You could just as well copy the NDP around provided you reserve
==enough space at the end of the skb.
==
==	Regards
==		Oliver
==
==
==
==

This might be true - so let's work on it. Reading the code I realized 
that the cdc_ncm_ndp() (which btw I would like to have renamed to cdc_ncm_ndp16 
as I did in a previous patchset), does something interesting here.
So - the function serches the already prepared frame for an appropriate NDP, 
as the comment suggests. It uses the signature to find one. Until now, moving 
the NDP at the end would pose no problems, even doing so dynamically (that's 
the final goal).
If the appropriate ndp is found, we return it, going ahead if this doesn't 
happen, updating our offset accordingly.
We return the ndp16 anyway for the function calling us to use it as reference.
Infact, the real copying of the ndp in the skb asI understand is happening 
here:
ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, 
ctx->max_ndp_size);

Infact we call cdc_ncm_align_tail (you can observe we call it here and also in 
cdc_ncm_fill_tx_frame()).

So I am trying to change this, having this function work in two mode:
- the direct allocation mode: that's how it works now
- the non direct allocation mode: where the caller should do this work

What do you think about this ? 

--
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8067b8f..bcd919d 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -978,9 +978,9 @@ static void cdc_ncm_align_tail(struct sk_buff *skb, size_t modulus, size_t remai
 }
 
 /* return a pointer to a valid struct usb_cdc_ncm_ndp16 of type sign, possibly
- * allocating a new one within skb
+ * allocating a new one within skb if in direct allocation mode (normal mode of operation).
  */
-static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign, size_t reserve)
+static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign, size_t reserve, unsigned int direct_allocation)
 {
 	struct usb_cdc_ncm_ndp16 *ndp16 = NULL;
 	struct usb_cdc_ncm_nth16 *nth16 = (void *)skb->data;
@@ -994,8 +994,9 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
 		ndpoffset = le16_to_cpu(ndp16->wNextNdpIndex);
 	}
 
-	/* align new NDP */
-	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+	/* align new NDP in case we're going to allocate it */
+	if (direct_allocation)
+	  cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
 
 	/* verify that there is room for the NDP and the datagram (reserve) */
 	if ((ctx->tx_max - skb->len - reserve) < ctx->max_ndp_size)
@@ -1008,10 +1009,12 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
 		nth16->wNdpIndex = cpu_to_le16(skb->len);
 
 	/* push a new empty NDP */
-	ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
-	ndp16->dwSignature = sign;
-	ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));
-	return ndp16;
+	if (direct_allocation) {
+	  ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
+  	ndp16->dwSignature = sign;
+  	ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));
+  	return ndp16;
+  }
 }
 
 struct sk_buff *
@@ -1071,7 +1074,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		}
 
 		/* get the appropriate NDP for this skb */
-		ndp16 = cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus + ctx->tx_remainder);
+		ndp16 = cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus + ctx->tx_remainder, 0);
 
 		/* align beginning of next frame */
 		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
