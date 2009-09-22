From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: request IRQ on activating the interface
Date: Tue, 22 Sep 2009 09:28:26 -0700
Message-ID: <20090922092826.5302225c@s6510>
References: <20090922120127.14242.71353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34313 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbZIVQ2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 12:28:30 -0400
In-Reply-To: <20090922120127.14242.71353.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Sep 2009 14:01:31 +0200
Michal Schmidt <mschmidt@redhat.com> wrote:

> skge requests IRQ in its probe function. This causes a problem in
> the following real-life scenario with two different NICs in the machine:
> 
> 1. modprobe skge
>    The card is detected as eth0 and requests IRQ 17. Directory
>    /proc/irq/17/eth0 is created.
> 2. There is an udev rule which says this interface should be called
>    eth1, so udev renames eth0 -> eth1.
> 3. modprobe 8139too
>    The Realtek card is detected as eth0. It will be using IRQ 17 too.
> 4. ip link set eth0 up
>    Now 8139too requests IRQ 17.
> 
> The result is:
> WARNING: at fs/proc/generic.c:590 proc_register ...
> proc_dir_entry '17/eth0' already registered
> ...
> 
> And "ls /proc/irq/17" shows two subdirectories, both called eth0.
> 
> Fix it by requesting the IRQ in skge when the interface is activated.
> This works, because interfaces can be renamed only while they are down.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

No. because two port cards have a single IRQ for both ports.
The choice of ethX in irq name was done because irqbalance looks for this.
Probably better to change skge/sky2 and other devices with same issue
to use skge-N ... for request_irq, and teach irqbalance how to do deal
with it.
