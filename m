From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: bnx2x - bnx2x_credit_pool_get_entry bug?
Date: Mon, 26 Mar 2012 22:14:33 -0700
Message-ID: <CAHo-OozR_OginBaH3yhwgdQBwxpcqfjakpBC-pOCQO8Bp2vM4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Linux NetDev <netdev@vger.kernel.org>,
	Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57435 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576Ab2C0FOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 01:14:34 -0400
Received: by obbeh20 with SMTP id eh20so6055085obb.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 22:14:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/bnx2x/bnx2x_sp.c:3850 contains in bnx2x_credit_pool_get_entry():

last modified in commit: 619c5cb6885b9 Vlad Zolotarov      2011-06-14
14:33:44 +0300

static bool bnx2x_credit_pool_get_entry(
        struct bnx2x_credit_pool_obj *o,
        int *offset)
{
        int idx, vec, i;

        *offset = -1;

        /* Find "internal cam-offset" then add to base for this object... */
        for (vec = 0; vec < BNX2X_POOL_VEC_SIZE; vec++) {

                /* Skip the current vector if there are no free entries in it */
                if (!o->pool_mirror[vec])
                        continue;

                /* If we've got here we are going to find a free entry */
                for (idx = vec * BNX2X_POOL_VEC_SIZE, i = 0;
                      i < BIT_VEC64_ELEM_SZ; idx++, i++)

                        if (BIT_VEC64_TEST_BIT(o->pool_mirror, idx)) {
                                /* Got one!! */
                                BIT_VEC64_CLEAR_BIT(o->pool_mirror, idx);
                                *offset = o->base_pool_offset + idx;
                                return true;
                        }
        }

        return false;
}

drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h:301:#define
MAX_MAC_CREDIT_E2 272 /* Per Path */
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h:640:#define
BNX2X_POOL_VEC_SIZE  (MAX_MAC_CREDIT_E2 / 64)
drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:385:#define
BIT_VEC64_ELEM_SZ               64

looks to me like idx = vec * BNX2X_POOL_VEC_SIZE should actually be
idx = vec * BIT_VEC64_ELEM_SZ

Found this while trying to debug an E1 multicast problem in an older
bnx2x driver and looking upstream for inspiration.

- Maciej
