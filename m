From: Jiri Slaby <jirislaby@gmail.com>
Subject: [HELP] ATM: mpc, use-after-free
Date: Mon, 11 Oct 2010 09:56:44 +0200
Message-ID: <4CB2C33C.8080109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: ML netdev <netdev@vger.kernel.org>,
	linux-atm-general@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>, chas@cmf.nrl.navy.mil
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Stanse found this use-after-free:

static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
{
...
        new_skb = skb_realloc_headroom(skb, eg->ctrl_info.DH_length);

        dev_kfree_skb_any(skb);

FREE    ^^^^^^^^^^^^^^^^^^^^^^^

        if (new_skb == NULL) {
                mpc->eg_ops->put(eg);
                return;
        }
        skb_push(new_skb, eg->ctrl_info.DH_length);
        skb_copy_to_linear_data(new_skb, eg->ctrl_info.DLL_header,
                                eg->ctrl_info.DH_length);
 ...
        memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));

USE            ^^^^^^^^^^^^

        netif_rx(new_skb);

I guess it should be ATM_SKB(new_skb), right?

The two problems are:
1) obvious use-after-free
2) ?data leak, since we don't erase the right memory?

thanks,
-- 
js
