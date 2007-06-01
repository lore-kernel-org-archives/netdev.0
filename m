From: "Laurent Chavey" <chavey@google.com>
Subject: [PATCH]: bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 1 Jun 2007 09:33:42 -0700
Message-ID: <97949e3e0706010933h6921ca72p9858daa229bcfce6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8666 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762139AbXFAQdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 12:33:51 -0400
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id l51GXmnQ030151
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 17:33:48 +0100
Received: from an-out-0708.google.com (andd17.prod.google.com [10.100.30.17])
	by spaceape8.eur.corp.google.com with ESMTP id l51GXh94015228
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 17:33:43 +0100
Received: by an-out-0708.google.com with SMTP id d17so173818and
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 09:33:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%diff -ru linux-2.6.21.3/drivers/net/bonding/bond_3ad.c
linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c
--- linux-2.6.21.3/drivers/net/bonding/bond_3ad.c       2007-05-24
14:22:47.000000000 -0700
+++ linux-2.6.21.3.new/drivers/net/bonding/bond_3ad.c   2007-06-01
09:28:07.000000000 -0700
@@ -2312,10 +2312,7 @@
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
-       struct aggregator *agg;
-
-       agg = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
-       if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
+       if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
                if (!netif_carrier_ok(bond->dev)) {
                        netif_carrier_on(bond->dev);
                        return 1;


On 5/31/07, Laurent Chavey <chavey@google.com> wrote:
> if a host configured with 802.3ad bond mode is connected to a switch
> that does not support 802.3ad,  then an aggregator is selected as the
> active aggregator (first link that has carrier in the slave list).
> This is perfectly fine, since it lets at least one of the link become active.
> (this was the behavior prior to 2.6.18)
>
> In 2.6.18 and above, a new check for the partner mac address was added
> before an aggregator's carrier is set on. If a host is  configured as
> previously
> described,  then no links will become active.
>
> is that the intended behavior ?
>
>
> -----
> in the scenario described here, the partner mac address is always set to NULL.
> so the statement is always false.
>
>         if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
>                 if (!netif_carrier_ok(bond->dev)) {
>                         netif_carrier_on(bond->dev);
>                         return 1;
>                 }
>                 return 0;
>         }
> ----
>
