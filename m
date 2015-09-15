From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: fjes: update_zone_task
Date: Tue, 15 Sep 2015 02:07:52 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54278CA7@G01JPEXMBYT01>
References: <20150914013207.GA18438@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:31788 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbbIOCH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 22:07:56 -0400
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id ACB79AC029E
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 11:07:53 +0900 (JST)
In-Reply-To: <20150914013207.GA18438@mwanda>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Dan,

  Thanks for pointing!
  I'll check that soon.

  Sincerely,
  Taku Izumi

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Monday, September 14, 2015 10:32 AM
> To: Izumi, Taku/泉 拓
> Cc: netdev@vger.kernel.org
> Subject: re: fjes: update_zone_task
> 
> Hello Taku Izumi,
> 
> The patch 785f28e061a8: "fjes: update_zone_task" from Aug 21, 2015,
> leads to the following static checker warning:
> 
> 	drivers/net/fjes/fjes_hw.c:1016 fjes_hw_update_zone_task()
> 	warn: potential off by one 'info[]' limit 'hw->max_epid'
> 
> drivers/net/fjes/fjes_hw.c
>    963          case 0:
>    964
>    965                  for (epidx = 0; epidx < hw->max_epid; epidx++) {
>    966                          if (epidx == hw->my_epid) {
>    967                                  hw->ep_shm_info[epidx].es_status =
>    968                                          info[epidx].es_status;
>    969                                  hw->ep_shm_info[epidx].zone =
>    970                                          info[epidx].zone;
>    971                                  continue;
>    972                          }
>    973
>    974                          pstatus = fjes_hw_get_partner_ep_status(hw, epidx);
>    975                          switch (pstatus) {
>    976                          case EP_PARTNER_UNSHARE:
>    977                          default:
>    978                                  if ((info[epidx].zone !=
>    979                                          FJES_ZONING_ZONE_TYPE_NONE) &&
>    980                                      (info[epidx].es_status ==
>    981                                          FJES_ZONING_STATUS_ENABLE) &&
>    982                                      (info[epidx].zone ==
>    983                                          info[hw->my_epid].zone))
>    984                                          set_bit(epidx, &share_bit);
>    985                                  else
>    986                                          set_bit(epidx, &unshare_bit);
>    987                                  break;
>    988
>    989                          case EP_PARTNER_COMPLETE:
>    990                          case EP_PARTNER_WAITING:
>    991                                  if ((info[epidx].zone ==
>    992                                          FJES_ZONING_ZONE_TYPE_NONE) ||
>    993                                      (info[epidx].es_status !=
>    994                                          FJES_ZONING_STATUS_ENABLE) ||
>    995                                      (info[epidx].zone !=
>    996                                          info[hw->my_epid].zone)) {
>    997                                          set_bit(epidx,
>    998                                                  &adapter->unshare_watch_bitmask);
>    999                                          set_bit(epidx,
>   1000                                                  &hw->hw_info.buffer_unshare_reserve_bit);
>   1001                                  }
>   1002                                  break;
>   1003
>   1004                          case EP_PARTNER_SHARED:
>   1005                                  if ((info[epidx].zone ==
>   1006                                          FJES_ZONING_ZONE_TYPE_NONE) ||
>   1007                                      (info[epidx].es_status !=
>   1008                                          FJES_ZONING_STATUS_ENABLE) ||
>   1009                                      (info[epidx].zone !=
>   1010                                          info[hw->my_epid].zone))
>   1011                                          set_bit(epidx, &irq_bit);
>   1012                                  break;
>   1013                          }
>   1014                  }
>   1015
>   1016                  hw->ep_shm_info[epidx].es_status = info[epidx].es_status;
>   1017                  hw->ep_shm_info[epidx].zone = info[epidx].zone;
> 
> 
> I'm not sure how Smatch is able to generate this warning.  The array is
> allocated using the FJES_DEV_REQ_BUF_SIZE(hw->max_epid) macro.  It
> really has a lot of obfuscation layers so I wasn't able to understand
> it.
> 
> It seems like this might be a real bug though.  I suspect the fix is to
> change the continue on line 970 to a break and delete lines 1016 and
> 1017?
> 
>   1018
>   1019                  break;
>   1020          }
> 
> regards,
> dan carpenter
