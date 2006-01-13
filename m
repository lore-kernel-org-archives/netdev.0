From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: Tx packet fragmentation?
Date: Fri, 13 Jan 2006 13:00:39 +0200
Message-ID: <200601131300.39276.vda@ilport.com.ua>
References: <20060112165853.GA17789@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andim2@users.sourceforge.net>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
In-Reply-To: <20060112165853.GA17789@rhlx01.fht-esslingen.de>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Thursday 12 January 2006 18:58, Andreas Mohr wrote:
> Hi,
> 
> I'd like to ask some things about packet fragmentation (you remember I wanted
> to work on this due to my very bad link quality?). I'm asking now since I
> will probably have some time during the weekend to work on it.
> 
> Problem is that fragmenting packets requires allocating several tx descriptors
> in a row, then preparing and sending the data packet piecemeal via those
> various descriptors in acx_l_tx_data().
> Do you have any recommendations on how to do it?
> (the split between acx_l_alloc_tx() and acx_l_tx_data() is a bit problematic)

Basically you want to modify this part of acx_i_start_xmit():

        tx = acx_l_alloc_tx(priv);
        if (unlikely(!tx)) {
                printk_ratelimited("%s: start_xmit: txdesc ring is full, "
                        "dropping tx\n", dev->name);
                txresult = NOT_OK;
                goto end;
        }

        txbuf = acx_l_get_txbuf(priv, tx);
        if (unlikely(!txbuf)) {
                /* Card was removed */
                txresult = NOT_OK;
                acx_l_dealloc_tx(priv, tx);
                goto end;
        }
        len = acx_ether_to_txbuf(priv, txbuf, skb);
        if (unlikely(len < 0)) {
                /* Error in packet conversion */
                txresult = NOT_OK;
                acx_l_dealloc_tx(priv, tx);
                goto end;
        }
        acx_l_tx_data(priv, tx, len);

As seen here, current code produces and tx'es just one wlan packet.

Possible adaptation:

struct frag_vec {
	int len;
	void *tx;
	void *txbuf;
};
/* allocates and fills from 1 to N wlan fragments */
int acx_ether_to_frags(wlandevice_t *priv, const struct sk_buff *skb, struct frag_vec *frag, int len);


acx_i_start_xmit():

	struct frag_vec frag[N];
	...
        n = acx_ether_to_frags(priv, skb, frag, N);
        if (n <= 0) {
                /* Error in packet conversion */
                txresult = NOT_OK;
                goto end;
        }
	for(1..n)
	        acx_l_tx_data(priv, frag[i].tx, frag[i].len);

> Or should this be the job of the OS to care about fragmenting the packets
> to be sent? (then it would just call our data tx stuff multiple times itself
> anyway).

Yes, it must be done by softmac layer.

> And what about the multiple host txhostdescs that we (need to?) initialize
> in order to work around "bugs"?

It should not matter here, you won't even need to touch pci.c
except for maybe setting some FIRSTFRAG and/or MORE_FRAG bits
as appropriate.

> Are we sure that this is a bug of specific(???) cards or not simply a bug of
> certain firmware versions or even a bug in our driver? (maybe due to doing
> some things in weird ways that the firmware totally doesn't expect?).

I think firmware was debugged only to meet needs of Windows driver.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
