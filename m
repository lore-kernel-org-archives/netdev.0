From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Fri, 28 Mar 2008 00:36:59 +0100
Message-ID: <200803280036.59311.vda.linux@googlemail.com>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi> <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752960AbYC0XjA@vger.kernel.org>
In-Reply-To: <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 March 2008 13:38, Ilpo J=E4rvinen wrote:
> Allyesconfig (v2.6.24-mm1):
>=20
> -23668  392 funcs, 104 +, 23772 -, diff: -23668 --- dev_alloc_skb
>=20
> Without many debug CONFIGs (v2.6.25-rc2-mm1):
>=20
> -12178  382 funcs, 157 +, 12335 -, diff: -12178 --- dev_alloc_skb
> dev_alloc_skb                 |  +37


This will be very confusing for casual reader:

> +struct sk_buff *dev_alloc_skb(unsigned int length)
> +{
> +	return __dev_alloc_skb(length, GFP_ATOMIC);
> +}
> +EXPORT_SYMBOL(dev_alloc_skb);

"what, they want to save one push instruction per callsite??".

Can you add a comment which explains the intent?

+struct sk_buff *dev_alloc_skb(unsigned int length)
+{
+       /* There is more code here than it seems:
+        * __dev_alloc_skb is an inline */
+	return __dev_alloc_skb(length, GFP_ATOMIC);
+}
+EXPORT_SYMBOL(dev_alloc_skb);


Another good chunk of code size saving can be achieved
by introducing dev_alloc_skb_or_warn(), and using it
in places like these:

drivers/net/irda/nsc-ircc.c:

                        skb =3D dev_alloc_skb(len+1);
                        if (skb =3D=3D NULL)  {
                                IRDA_WARNING("%s(), memory squeeze, "
                                             "dropping frame.\n",
                                             __FUNCTION__);

drivers/net/appletalk/ltpc.c:

        skb =3D dev_alloc_skb(3+sklen);
        if (skb =3D=3D NULL)
        {
                printk("%s: dropping packet due to memory squeeze.\n",

net/econet/af_econet.c:

        newskb =3D alloc_skb((len - sizeof(struct aunhdr) + 15) & ~15,
                           GFP_ATOMIC);
        if (newskb =3D=3D NULL)
        {
                printk(KERN_DEBUG "AUN: memory squeeze, dropping packet=
=2E\n");
                /* Send nack and hope sender tries again */
                goto bad;
        }

(hmm, this last one also wants s/alloc_skb(GFP_ATOMIC)/dev_alloc_skb/)

--
vda
