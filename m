From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tap: reference to KVA of an unloaded module causes
 kernel panic
Date: Sat, 28 Oct 2017 19:23:35 +0900 (KST)
Message-ID: <20171028.192335.1556601044987470204.davem@davemloft.net>
References: <1509087616-28222-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sainath.grandhi@intel.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdJ1KXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 06:23:38 -0400
In-Reply-To: <1509087616-28222-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Fri, 27 Oct 2017 00:00:16 -0700

> The commit 9a393b5d5988 ("tap: tap as an independent module") created a
> separate tap module that implements tap functionality and exports
> interfaces that will be used by macvtap and ipvtap modules to create
> create respective tap devices.
> 
> However, that patch introduced a regression wherein the modules macvtap
> and ipvtap can be removed (through modprobe -r) while there are
> applications using the respective /dev/tapX devices. These applications
> cause kernel to hold reference to /dev/tapX through 'struct cdev
> macvtap_cdev' and 'struct cdev ipvtap_dev' defined in macvtap and ipvtap
> modules respectively. So,  when the application is later closed the
> kernel panics because we are referencing KVA that is present in the
> unloaded modules.
> 
> ----------8<------- Example ----------8<----------
> $ sudo ip li add name mv0 link enp7s0 type macvtap
> $ sudo ip li show mv0 |grep mv0| awk -e '{print $1 $2}'
>   14:mv0@enp7s0:
> $ cat /dev/tap14 &
> $ lsmod |egrep -i 'tap|vlan'
> macvtap                16384  0
> macvlan                24576  1 macvtap
> tap                    24576  3 macvtap
> $ sudo modprobe -r macvtap
> $ fg
> cat /dev/tap14
> ^C
> 
> <...system panics...>
> BUG: unable to handle kernel paging request at ffffffffa038c500
> IP: cdev_put+0xf/0x30
> ----------8<-----------------8<----------
> 
> The fix is to set cdev.owner to the module that creates the tap device
> (either macvtap or ipvtap). With this set, the operations (in
> fs/char_dev.c) on char device holds and releases the module through
> cdev_get() and cdev_put() and will not allow the module to unload
> prematurely.
> 
> Fixes: 9a393b5d5988ea4e (tap: tap as an independent module)
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied and queued up for -stable.
