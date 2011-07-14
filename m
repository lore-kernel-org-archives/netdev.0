From: Flavio Leitner <fbl@redhat.com>
Subject: preempting while holding rtnl_lock
Date: Thu, 14 Jul 2011 18:15:02 -0300
Message-ID: <20110714181502.4a5602aa@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231Ab1GNVPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 17:15:04 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6ELF4AA013467
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 17:15:04 -0400
Received: from asterix.rh (ovpn-113-118.phx2.redhat.com [10.3.113.118])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6ELF32W000942
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2011 17:15:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I was reviewing driver sources and found that
ethtool ops holds rtnl_lock() and there are few
drivers (for example: tg3, bnx2) that use napi_disable()
in this context.

/**     
 *      napi_disable - prevent NAPI from scheduling
 *      @n: napi context
 *              
 * Stop NAPI from being scheduled on this context.
 * Waits till any outstanding processing completes.
 */
static inline void napi_disable(struct napi_struct *n)
{
        set_bit(NAPI_STATE_DISABLE, &n->state);
        while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
                msleep(1);
        clear_bit(NAPI_STATE_DISABLE, &n->state);
}

The msleep() above will preempt.  I believe this is wrong.
See the functions below as examples:
bnx2_set_ringparam()
+ bnx2_change_ring_size()
  + bnx2_netif_stop()
    + bnx2_napi_disable()
      + napi_disable()


+ tg3_change_mtu() = ndo_change_mtu
  + tg3_netif_stop()
    + tg3_napi_disable()
      + napi_disable()

What am I missing?
thanks,
fbl
