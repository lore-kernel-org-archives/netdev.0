From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: net-caif: add CAIF core protocol stack
Date: Tue, 2 Dec 2014 16:40:50 +0300
Message-ID: <20141202134050.GA27113@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50033 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932292AbaLBNlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 08:41:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sjur Braendeland,

The patch b482cd2053e3: "net-caif: add CAIF core protocol stack" from
Mar 30, 2010, leads to the following static checker warning:

	net/caif/cfctrl.c:440 cfctrl_recv()
	error: potentially using uninitialized 'tmp'.

net/caif/cfpkt_skbuff.c
   124  int cfpkt_extr_head(struct cfpkt *pkt, void *data, u16 len)
   125  {
   126          struct sk_buff *skb = pkt_to_skb(pkt);
   127          u8 *from;
   128          if (unlikely(is_erronous(pkt)))
   129                  return -EPROTO;
   130  
   131          if (unlikely(len > skb->len)) {
   132                  PKT_ERROR(pkt, "read beyond end of packet\n");
   133                  return -EPROTO;
   134          }
   135  
   136          if (unlikely(len > skb_headlen(skb))) {
                             ^^^^^^^^^^^^^^^^^^^^^
Assume we can hit this condition with "len == 1".  I don't know if
that's possible.

   137                  if (unlikely(skb_linearize(skb) != 0)) {
   138                          PKT_ERROR(pkt, "linearize failed\n");
   139                          return -EPROTO;
   140                  }
   141          }
   142          from = skb_pull(skb, len);
   143          from -= len;
   144          if (data)
   145                  memcpy(data, from, len);
   146          return 0;
   147  }
   148  EXPORT_SYMBOL(cfpkt_extr_head);

net/caif/cfctrl.c
   430                          case CFCTRL_SRV_RFM:
   431                                  /* Construct a frame, convert
   432                                   * DatagramConnectionID
   433                                   * to network format long and copy it out...
   434                                   */
   435                                  cfpkt_extr_head(pkt, &tmp32, 4);
   436                                  linkparam.u.rfm.connid =
   437                                    le32_to_cpu(tmp32);
   438                                  cp = (u8 *) linkparam.u.rfm.volume;
   439                                  for (cfpkt_extr_head(pkt, &tmp, 1);
   440                                       cfpkt_more(pkt) && tmp != '\0';
                                                                ^^^^^^^^^^
cfpkt_more() would be true and "tmp" is uninitliazed so it is a forever
loop.

   441                                       cfpkt_extr_head(pkt, &tmp, 1))
   442                                          *cp++ = tmp;
   443                                  *cp = '\0';

regards,
dan carpenter
