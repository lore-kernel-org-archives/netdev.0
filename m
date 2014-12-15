From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in e1000/e1000e
Date: Mon, 15 Dec 2014 11:23:34 +0800
Message-ID: <000001d01816$8264dde0$872e99a0$@163.com>
References: <001301d0180a$f7cb74b0$e7625e10$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:39368 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbaLODXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 22:23:38 -0500
In-Reply-To: <001301d0180a$f7cb74b0$e7625e10$@163.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers in Linux 3.17.2, and find some
potential bugs.

e1000 driver:
The target file is drivers/net/ethernet/intel/e1000/e1000_main.c, which is
used to build e1000.ko. I hope you can help me check my findings:
[1] In the normal process, netif_napi_add is called in e1000_probe, but
netif_napi_del is not called in e1000_remove. However, many other ethernet
card drivers call them in pairs, even in the error handling paths, such as
r8169 and igb.

e1000e driver:
The target file is drivers/net/ethernet/intel/e1000e/netdev.c, which is used
to build e1000e.ko. I hope you can help me check my findings:
[1] In the normal process, netif_napi_add is called in e1000_probe, but
netif_napi_del is not called in e1000_remove. However, many other ethernet
card drivers call them in pairs, even in the error handling paths, such as
r8169 and igb.
[2] The function vzalloc is called by e1000e_setup_rx_resources (in
e1000_open) when initializing the ethernet card driver. But when vzalloc is
failed, "err" segment in e1000e_setup_rx_resources is executed to return,
and then e1000e_free_tx_resources in "err_setup_rx" segment in e1000_open is
executed to halt. However, "writel(0, tx_ring->head)" statement in
e1000_clean_tx_ring in e1000e_free_tx_resources will cause system crash,
because "tx_ring->head" is not assigned the value. In the code,
"tx_ring->head" is initialized in e1000_configure_tx in e1000_configure
after the e1000e_setup_rx_resources.
[3] The same system crashes with [2] happens, when kcalloc in
e1000e_setup_rx_resources is failed(returns NULL).
[4] The same system crashes with [2] happens, when e1000_alloc_ring_dma in
e1000e_setup_rx_resources is failed(returns error code).
[5] In the normal process of e1000e, pci_enable_pcie_error_reporting and
pci_disable_pcie_error_reporting is called in pairs in e1000_probe and
e1000_remove. However, when pci_enable_pcie_error_reporting has been called
and pci_save_state in e1000_probe is failed, "err_alloc_etherdev" segment in
e1000_probe is executed immediately to exit, but
pci_disable_pcie_error_reporting is not called.
[6] The same situation with [5] happens when alloc_etherdev_mqs in
e1000_probe is failed.
[7] The same situation with [5] happens when ioremap in e1000_probe is
failed.
[8] The same situation with [5] happens when e1000_sw_init in e1000_probe is
failed.
[9] The same situation with [5] happens when register_netdev in e1000_probe
is failed.
[10] When request_irq in e1000_request_irq is failed, pm_qos_add_request in
e1000_open is called, but pm_qos_remove_request is not called.

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Jia-Ju Bai
