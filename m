From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: 2.6.26rc9+git bluetooth/rfcomm oops
Date: Sun, 13 Jul 2008 18:25:54 +0200
Message-ID: <19f34abd0807130925g3001109cm6bdee9baad701960@mail.gmail.com>
References: <1215945125.4842.13.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_21806_19432089.1215966354630"
Cc: "Dave Young" <hidave.darkstar@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Soeren Sonnenburg" <kernel@nn7.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:51616 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbYGMQZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 12:25:55 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4508292wfd.4
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2008 09:25:54 -0700 (PDT)
In-Reply-To: <1215945125.4842.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_21806_19432089.1215966354630
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sun, Jul 13, 2008 at 12:32 PM, Soeren Sonnenburg <kernel@nn7.de> wrote:
> Hi,
>
> this oops happened after a couple of s2ram cycles so it might be very
> well crap. However I somehow triggered it by /etc/init.d/bluetooth
> stop/start's which also call hid2hci maybe even a connection was about
> to be established at that time. As I remember having seen a problem like
> this before I thought I report it (even though I have a madwifi tainted
> kernel).
>
> [drm] Num pipes: 1
> kobject_add_internal failed for rfcomm0 with -EEXIST, don't try to register things with the same name in the same directory.

Hi,

Thanks for the report.

I was able to reproduce your Oops:

kobject_add_internal failed for rfcomm0 with -EEXIST, don't try to
register things with the same name in the same directory.
Pid: 2534, comm: a.out Not tainted 2.6.26-rc9-00132-g9df2fe9 #24
 [<c0210161>] kobject_add_internal+0x108/0x13e
 [<c0210478>] kobject_add+0x4a/0x4e
 [<c026e258>] device_add+0x62/0x446
 [<c020feb9>] kobject_init+0x32/0x53
 [<c026e6c4>] device_create_vargs+0x78/0x99
 [<c026e707>] device_create+0x22/0x26
 [<c02521be>] tty_register_device+0x97/0xa2
 [<c0110000>] __cpu_disable+0x10b/0x130
 [<c03721c8>] sk_prot_alloc+0x1c/0x61
 [<c03ea86e>] rfcomm_dev_ioctl+0x213/0x582
 [<c03e9342>] rfcomm_sock_ioctl+0x1e/0x2d
 [<c03715c5>] sock_ioctl+0x152/0x175
 [<c0371473>] sock_ioctl+0x0/0x175
 [<c0166538>] vfs_ioctl+0x1c/0x5d
 [<c01667b6>] do_vfs_ioctl+0x23d/0x254
 [<c037119d>] sys_socketcall+0x51/0x181
 [<c01667f9>] sys_ioctl+0x2c/0x43
 [<c0103569>] sysenter_past_esp+0x6a/0x91
 =======================

This is because the device may be unregistered even though a reference
to it is held. When we try to register it again, the kobject layer
burps because the tty parts have not been unregistered yet. (This only
happens when the device is finally destroyed, i.e. no references.)

I don't know how to fix this, but I've attached a reproducer and added
a couple of Ccs.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

------=_Part_21806_19432089.1215966354630
Content-Type: text/x-csrc; name=rfcomm.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_filutq0c0
Content-Disposition: attachment; filename=rfcomm.c

I2luY2x1ZGUgPHN5cy9pb2N0bC5oPgojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5jbHVkZSA8
c3lzL3R5cGVzLmg+CiNpbmNsdWRlIDxzeXMvd2FpdC5oPgoKI2luY2x1ZGUgPGVycm5vLmg+CiNp
bmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGludC5oPgoj
aW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPHVuaXN0ZC5o
PgoKI2RlZmluZSBSRkNPTU1DUkVBVEVERVYJCV9JT1coJ1InLCAyMDAsIGludCkKI2RlZmluZSBS
RkNPTU1SRUxFQVNFREVWCV9JT1coJ1InLCAyMDEsIGludCkKI2RlZmluZSBCVFBST1RPX1JGQ09N
TSAgMwoKdHlwZWRlZiB1aW50OF90IHU4Owp0eXBlZGVmIHVpbnQzMl90IHUzMjsKdHlwZWRlZiBp
bnQxNl90IHMxNjsKdHlwZWRlZiB1aW50OF90IF9fdTg7CgovKiBCRCBBZGRyZXNzICovCnR5cGVk
ZWYgc3RydWN0IHsKCV9fdTggYls2XTsKfSBfX2F0dHJpYnV0ZV9fKChwYWNrZWQpKSBiZGFkZHJf
dDsKCnN0cnVjdCByZmNvbW1fZGV2X3JlcSB7CglzMTYgICAgICBkZXZfaWQ7Cgl1MzIgICAgICBm
bGFnczsKCWJkYWRkcl90IHNyYzsKCWJkYWRkcl90IGRzdDsKCXU4ICAgICAgIGNoYW5uZWw7Cn07
Cgp2b2lkIHJmY29tbShpbnQgcmVxdWVzdCwgaW50IGRldl9pZCkKewoJaW50IGZkID0gc29ja2V0
KFBGX0JMVUVUT09USCwgU09DS19TVFJFQU0sIEJUUFJPVE9fUkZDT01NKTsKCWlmIChmZCA9PSAt
MSkgewoJCWZwcmludGYoc3RkZXJyLCAic29ja2V0OiBlcnJvcjogJXNcbiIsIHN0cmVycm9yKGVy
cm5vKSk7CgkJZXhpdChFWElUX0ZBSUxVUkUpOwoJfQoKCXN0cnVjdCByZmNvbW1fZGV2X3JlcSBy
ZXE7CgltZW1zZXQoJnJlcSwgMCwgc2l6ZW9mKHJlcSkpOwoJcmVxLmRldl9pZCA9IGRldl9pZDsK
CXJlcS5jaGFubmVsID0gMTsKCglpZiAoaW9jdGwoZmQsIHJlcXVlc3QsICZyZXEpID09IC0xKSB7
CgkJZnByaW50ZihzdGRlcnIsICJpb2N0bDogZXJyb3I6ICVzXG4iLCBzdHJlcnJvcihlcnJubykp
OwoJCWV4aXQoRVhJVF9GQUlMVVJFKTsKCX0KCgl3aGlsZSAoY2xvc2UoZmQpID09IC0xICYmIGVy
cm5vID09IEVJTlRSKTsKfQoKaW50Cm1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkKewoJcGlk
X3QgY2hpbGQ7CgoJY2hpbGQgPSBmb3JrKCk7CglpZiAoY2hpbGQgPT0gLTEpIHsKCQlmcHJpbnRm
KHN0ZGVyciwgImZvcms6IGVycm9yOiAlc1xuIiwgc3RyZXJyb3IoZXJybm8pKTsKCQlleGl0KEVY
SVRfRkFJTFVSRSk7Cgl9CgoJaWYgKGNoaWxkID09IDApIHsKCQlwcmludGYoIkNyZWF0aW5nXG4i
KTsKCQlyZmNvbW0oUkZDT01NQ1JFQVRFREVWLCAwKTsKCgkJcHJpbnRmKCJPcGVuaW5nIC9kZXYv
cmZjb21tMC4uLlxuIik7CgoJCWludCBmZCA9IG9wZW4oIi9kZXYvcmZjb21tMCIsIE9fUkRXUiB8
IE9fTk9DVFRZKTsKCQlpZiAoZmQgPT0gLTEpIHsKCQkJZnByaW50ZihzdGRlcnIsICJvcGVuOiBl
cnJvcjogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7CgkJCXJmY29tbShSRkNPTU1SRUxFQVNFREVW
LCAwKTsKCQkJZXhpdChFWElUX0ZBSUxVUkUpOwoJCX0KCgkJZXhpdChFWElUX1NVQ0NFU1MpOwoJ
fQoKCXNsZWVwKDEpOwoKCS8qIFRoaXMgd2lsbCBkZWxldGUgdGhlIGRldmljZSwgYnV0IHNpbmNl
IHdlIHN0aWxsIGhvbGQgYSByZWZlcmVuY2UKCSAqIHRvIGl0IGluICJmZCIsIHRoZSB0dHkgd29u
J3QgYmUgdW5yZWdpc3RlcmVkIHlldC4uLiAqLwoJcHJpbnRmKCJSZWxlYXNpbmdcbiIpOwoJcmZj
b21tKFJGQ09NTVJFTEVBU0VERVYsIDApOwoKCS8qIEFuZCBub3cgd2UgdHJ5IHRvIHJlZ2lzdGVy
IHRoZSBzYW1lIHR0eSBkZXZpY2UuLi4gKi8KCXByaW50ZigiUmVjcmVhdGluZ1xuIik7CglyZmNv
bW0oUkZDT01NQ1JFQVRFREVWLCAwKTsKCgkvKiBDbGVhbnVwICovCglwcmludGYoIlJlbGVhc2lu
Z1xuIik7CglyZmNvbW0oUkZDT01NUkVMRUFTRURFViwgMCk7CgoJd2hpbGUgKDEpIHsKCQlpbnQg
c3RhdHVzOwoKCQlpZiAod2FpdCgmc3RhdHVzKSA9PSAtMSkgewoJCQlpZiAoZXJybm8gPT0gRUNI
SUxEKQoJCQkJYnJlYWs7CgoJCQlmcHJpbnRmKHN0ZGVyciwgIndhaXQ6IGVycm9yOiAlc1xuIiwg
c3RyZXJyb3IoZXJybm8pKTsKCQkJZXhpdChFWElUX0ZBSUxVUkUpOwoJCX0KCX0KCglyZXR1cm4g
RVhJVF9TVUNDRVNTOwp9Cg==
------=_Part_21806_19432089.1215966354630--
