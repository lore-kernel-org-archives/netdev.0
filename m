From: Anton Volkov <avolkov@ispras.ru>
Subject: Possible race in ks8851_mll.ko
Date: Tue, 15 Aug 2017 18:57:32 +0300
Message-ID: <49e80d06-531e-178e-1cb0-3293f275847f@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: david.choi@micrel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

While searching for races in the Linux kernel I've come across
"drivers/net/ethernet/micrel/ks8851_mll.ko" module. Here is a question 
that I came up with while analyzing results. Lines are given using the 
info from Linux v4.12.

Consider the following case:

Thread 1:                    Thread 2:
ks8851_probe
   ks = netdev_priv(netdev)
   register_netdev
                              ks_start_xmit
->ks_soft_reset              ->ks_tx_fifo_space
   ->ks_wrreg16                 ->ks_rdreg16
       ks->cmd_reg_cache = ...      ks->cmd_reg_cache = ...
       (ks8851_mll.c: line 536)     (ks8851_mll.c: line 505)
       iowrite16(ks->cmd_reg_cache) iowrite16(ks->cmd_reg_cache)

In this case early registration of netdev leads to callback interference 
in the initialization process. Both ks_wrreg16() and ks_rdreg16() use 
the same ks. If one of them changes the ks->cmd_reg_cache it is possible 
that both will use the same value though it should be different. Is this 
race feasible from your point of view?

Thank you for your time.

-- Anton Volkov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: avolkov@ispras.ru
