From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Follow-on: [OOPS] 2.4.25 fealnx: oops with heavy UDP traffic
Date: Wed, 24 Mar 2004 10:26:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <18084317552.20040324102634@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I played with gcc -S a bit.

drivers/net/fealnx.c:netdev_rx():
                        if (pkt_len < rx_copybreak &&
                            (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
                                skb->dev = dev;
                                skb_reserve(skb, 2);    /* 16 byte align the IP header */
                                /* Call copy + cksum if available. */
#if ! defined(__alpha__)
                                eth_copy_and_sum(skb,
                                        np->cur_rx->skbuff->tail, pkt_len, 0);
                                skb_put(skb, pkt_len);
#else
                                memcpy(skb_put(skb, pkt_len),
                                        np->cur_rx->skbuff->tail, pkt_len);
#endif
                        } else {
                                skb_put(skb = np->cur_rx->skbuff, pkt_len);
                                              ^^^^^^^^^^^^^^^^^^
oops happens here, np->cur_rx->skbuff is NULL

                                np->cur_rx->skbuff = NULL;
                                if (np->really_rx_count == RX_RING_SIZE)
                                        np->lack_rxbuf = np->cur_rx;
                                --np->really_rx_count;
                        }
--
vda
