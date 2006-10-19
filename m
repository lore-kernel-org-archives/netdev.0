From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: watchdog timeout panic in e1000 driver
Date: Thu, 19 Oct 2006 19:19:33 +0900
Message-ID: <45375135.5050206@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809070903090403050302"
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:63948 "EHLO
	tyo202.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1423270AbWJSKTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 06:19:35 -0400
Received: from mailgate3.nec.co.jp (mailgate53.nec.co.jp [10.7.69.161] (may be forged))
	by tyo202.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id k9JAJXsk027827
	for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 19:19:33 +0900 (JST)
Received: (from root@localhost) by mailgate3.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id k9JAJXG25818 for netdev@vger.kernel.org; Thu, 19 Oct 2006 19:19:33 +0900 (JST)
Received: from saigo.jp.nec.com (saigo.jp.nec.com [10.26.220.6]) by mailsv5.nec.co.jp (8.11.7/3.7W-MAILSV4-NEC) with ESMTP
	id k9JAJWo26105 for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 19:19:32 +0900 (JST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030809070903090403050302
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Hi,

A watchdog timeout panic occurred in e1000 driver (7.2.9-NAPI).
If e1000_watchdog is called when processing ioctl from ethtool, the system
could stop inside e1000_watchdog interrupt handler for about 16 seconds,
and the system panicked as a result of a watchdog timeout.

This problem only occurs on a server using ethernet controller inside
631xESB/632xESB, and NMI watchdog enabled.

Environment:
  OS     : RHEL4U3(x86_64)
  kernel : 2.6.9-34.ELsmp
  e1000  : 7.2.9-NAPI
  Ethernet controller : Intel Corporation 631x/632xESB DPT LAN Controller
                        Copper (rev 01)
  Watchdog timer should be enabled with a timeout period of less than 16
  seconds.

Steps to reproduce:
  Please apply the attached patch (ethtool.patch) to ethtool (VERSION 5) source
  code. Run make, and rename the freshly built ethtool as gsetloop.
  Put gsetloop and the attached shell script (gloop.sh) in the same directory,
  and execute gloop.sh. The problem should occur within about 5 minutes.

Cause:
  The problem occurs in the following steps.
   - ioctl is executed in ethtool.
      - e1000_read_phy_reg() is called from ioctl to read the value from phy
        register.
      - e1000_get_hw_eeprom_semaphore() is called from e1000_read_phy_reg() to
        acquire a semaphore.
      - E1000_SWSM_SWESMBI bit that is FW semaphore bit is set in
        e1000_get_hw_eeprom_semaphore().
      - When this bit was set, E1000_SWSM_SMBI bit that is driver's semaphore
        bit is also set.
   - e1000_watchdog() of interrupt handler is executed before the
     E1000_SWSM_SMBI bit is unset.
      - e1000_read_phy_reg() is called from e1000_watchdog() to read the value
        from phy register.
      - e1000_get_software_semaphore() is called from e1000_watchdog to confirm
        whether interruption handler can acquire a semaphore.
        This function confirms whether E1000_SWSM_SMBI bit is being set.
      - Therefore the process does loop for "hw->eeprom.word_size + 1" msec
        in e1000_get_software_semaphore().
        The value of "hw->eeprom.word_size + 1" was 16385 on my system.
        In other words it loops for 16.385 sec in
        e1000_get_software_semaphore().
        If NMI watchdog is enabled, the system will panic by NMI watchdog
        within this loop.

Fix:
  In kernels before 2.6.17, the e1000_watchdog() interrupt handler schedules
  e1000_watchdog_task(). The semaphore is acquired within this task, after
  ioctl processing for ethtool is finished, and this problem is avoided.

  e1000_watchdog_task() was remove by the following patch.

http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=2db10a081c5c1082d58809a1bcf1a6073f4db160
     e1000: rework driver hardware reset locking
     >After studying the driver mac reset code it was found that there
     >were multiple race conditions possible to reset the unit twice or
     >bring it e1000_up() double. This fixes all occurences where the
     >driver needs to reset the mac.
     >
     >We also remove irq requesting/releasing into _open and _close so
     >that while the device is _up we will never touch the irq's. This fixes
     >the double free irq bug that people saw.
     >
     >To make sure that the watchdog task doesn't cause another race we let
     >it run as a non-scheduled task.

  I'm not sure whether there was any reason to actively remove
  e1000_watchdog_task(). I think that removing e1000_watchdog_task() was a
  mistake, and it should be brought back in.
--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)



--------------030809070903090403050302
Content-Type: text/plain;
 name="gloop.sh"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="gloop.sh"

IyEvYmluL3NoCgpuPTY0Cmk9MQpbICQjIC1nZSAxIF0gJiYgbj0kMQoKd2hpbGUgWyAkaSAt
bGUgJG4gXQpkbwoJLi9nc2V0bG9vcCBldGgwICYKCWk9YGV4cHIgJGkgKyAxYApkb25lCg==
--------------030809070903090403050302
Content-Type: text/plain;
 name="ethtool.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ethtool.patch"

ZGlmZiAtdXJwTiBldGh0b29sX2dpdC9ldGh0b29sLmMgbXktZXRodG9vbC9ldGh0b29sLmMK
LS0tIGV0aHRvb2xfZ2l0L2V0aHRvb2wuYwkyMDA2LTEwLTE4IDE0OjE3OjEwLjAwMDAwMDAw
MCArMDkwMAorKysgbXktZXRodG9vbC9ldGh0b29sLmMJMjAwNi0xMC0xOCAxNDoxODo0NS4w
MDAwMDAwMDAgKzA5MDAKQEAgLTE1NzYsNyArMTU3Niw5IEBAIHN0YXRpYyBpbnQgZG9fZ3Nl
dChpbnQgZmQsIHN0cnVjdCBpZnJlcSAKIAogCWVjbWQuY21kID0gRVRIVE9PTF9HU0VUOwog
CWlmci0+aWZyX2RhdGEgPSAoY2FkZHJfdCkmZWNtZDsKLQllcnIgPSBpb2N0bChmZCwgU0lP
Q0VUSFRPT0wsIGlmcik7CisJZm9yICg7OykgeworCQllcnIgPSBpb2N0bChmZCwgU0lPQ0VU
SFRPT0wsIGlmcik7CisJfQogCWlmIChlcnIgPT0gMCkgewogCQllcnIgPSBkdW1wX2VjbWQo
JmVjbWQpOwogCQlpZiAoZXJyKQo=
--------------030809070903090403050302--
