From: Adrian Bunk <bunk@kernel.org>
Subject: drivers/net/niu.c: possible array overflows
Date: Sun, 14 Oct 2007 19:50:24 +0200
Message-ID: <20071014175024.GH4211@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@sunset.davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:35237 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758182AbXJNRty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 13:49:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following in drivers/net/niu.c:

<--  snip  -->

...
static int __devinit niu_pci_probe_sprom(struct niu *np)
{
...
        val = nr64(ESPC_MOD_STR_LEN);
        niudbg(PROBE, "SPROM: MOD_STR_LEN[%llu]\n",
               (unsigned long long) val);
        if (val > 8 * 4)
                return -EINVAL;

        for (i = 0; i < val; i += 4) {
                u64 tmp = nr64(ESPC_NCR(5 + (i / 4)));

                np->vpd.model[i + 3] = (tmp >>  0) & 0xff;
                np->vpd.model[i + 2] = (tmp >>  8) & 0xff;
                np->vpd.model[i + 1] = (tmp >> 16) & 0xff;
                np->vpd.model[i + 0] = (tmp >> 24) & 0xff;
        }
        np->vpd.model[val] = '\0';

        val = nr64(ESPC_BD_MOD_STR_LEN);
        niudbg(PROBE, "SPROM: BD_MOD_STR_LEN[%llu]\n",
               (unsigned long long) val);
        if (val > 4 * 4)
                return -EINVAL;

        for (i = 0; i < val; i += 4) {
                u64 tmp = nr64(ESPC_NCR(14 + (i / 4)));

                np->vpd.board_model[i + 3] = (tmp >>  0) & 0xff;
                np->vpd.board_model[i + 2] = (tmp >>  8) & 0xff;
                np->vpd.board_model[i + 1] = (tmp >> 16) & 0xff;
                np->vpd.board_model[i + 0] = (tmp >> 24) & 0xff;
        }
        np->vpd.board_model[val] = '\0';
...

<--  snip  -->

Check where the '\0's get written if "val" has the maximum non-EINVAL 
value.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

