From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Mon, 16 Mar 2009 21:24:14 +0800
Message-ID: <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00504502ccc3e05c4f04653c5d96
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759471AbZCPNYb@vger.kernel.org>
In-Reply-To: <20090315202603.GA9077@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--00504502ccc3e05c4f04653c5d96
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On Mon, Mar 16, 2009 at 4:26 AM, Ingo Molnar <mingo@elte.hu> wrote:
> * Johannes Berg <johannes@sipsolutions.net> wrote:
>> that the commit he quotes doesn't even change the driver he's
>> working with.

Here's what I did, and it's repeatable.

Take the attached bisect log and replay it, and the last offending
commit is this ...
# git log
commit 71c11fb57b924c160297ccd9e1761db598d00ac2
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Oct 28 18:29:48 2008 +0100

    b43/legacy: remove SSID code

Yes, this is not the real problem, but it's the last commit that cause
the problem, and I couldn't bisect further, typing the next "git
bisect bad" and the commit is

# git bisect bad
71c11fb57b924c160297ccd9e1761db598d00ac2 is first bad commit
commit 71c11fb57b924c160297ccd9e1761db598d00ac2
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Oct 28 18:29:48 2008 +0100

    b43/legacy: remove SSID code


Johannes, Ok, this is not the commit causing the problem, but anything
after this commit doesn't associate with my hidden APs. I may not have
run over every single commits since, but 2.6.29-rc8 is definitely not
associating at all automatically -- only manually by specifying the
AP.

This bug is quite hard to trigger, and it doesn't shows easily in
2.6.28-rc3. May be once every 10 times you tried.



# git reset --hard 71c11fb57b924c160297ccd9e1761db598d00ac2

I've tried on two different Linksys's AP. Association with WAG354G  is
better than with WAG200G ... meaning it's harder to get association
failure on 2.6.28-rc3. 1/10 fail on WAG354G, and 9/10 fails on
WAG200G.

Here's how I associate with the AP.

# modprobe -r iwlagn
# modprobe iwlagn
# iwconfig wlan0 mode Managed
# ifconfig wlan0 up
# iwconfig wlan0 essid "myessid"
# iwconfig wlan0 key restricted "hex key"
# iwconfig wlan0 ap auto channel auto
# ... wait for association
# ping -c 3 <IP of the AP>
# shutdown the interface
# ifconfig wlan0 down
# modprobe -r iwlagn


Repeat these and it'll fail to associate. On WAG200G, can't associate
after 2nd attempt.


Next revert these two commits

commit 4607816f608b42a5379aca97ceed08378804c99f
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Oct 28 18:25:43 2008 +0100

    iwlwifi: remove unused essid variable

commit a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Oct 28 18:21:05 2008 +0100

    iwlwifi: remove implicit direct scan


With these patches reverted, associating with the APs are always
successful 10 out of 10 times with the same steps as above.

I've even used the bad modules and when it failed, I can associate
again with the patched module. Same 2.6.28-rc3 kernel.


Here's part of the dmesg
cfg80211: Using static regulatory domain info
cfg80211: Regulatory domain: US
        (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
        (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
        (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
cfg80211: Calling CRDA for country: US
iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, 1.3.27ks
iwlagn: Copyright(c) 2003-2008 Intel Corporation
iwlagn 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:03:00.0: setting latency timer to 64
iwlagn: Detected Intel Wireless WiFi Link 4965AGN REV=0x4
iwlagn: Tunable channels: 11 802.11bg, 13 802.11a channels
iwlagn 0000:03:00.0: PCI INT A disabled
wmaster0 (iwlagn): not using net_device_ops yet
phy0: Selected rate control algorithm 'iwl-agn-rs'
wlan0 (iwlagn): not using net_device_ops yet
iwlagn 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
iwlagn 0000:03:00.0: restoring config space at offset 0x1 (was
0x100102, writing 0
x100106)
iwlagn 0000:03:00.0: irq 28 for MSI/MSI-X
iwlagn 0000:03:00.0: firmware: requesting iwlwifi-4965-2.ucode
iwlagn loaded firmware version 228.57.2.23
Registered led device: iwl-phy0:radio
Registered led device: iwl-phy0:assoc
Registered led device: iwl-phy0:RX
Registered led device: iwl-phy0:TX
iwlagn: TX Power requested while scanning!

Anything I can help to debug further, just let me know.

Thanks,
Jeff.

--00504502ccc3e05c4f04653c5d96
Content-Type: application/octet-stream; name="bisect.log"
Content-Disposition: attachment; filename="bisect.log"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fsd5ozkt0

Z2l0IGJpc2VjdCBzdGFydAojIGJhZDogWzAxOTFiNjI1Y2E1YTQ2MjA2ZDJmYjg2MmJiMDhmMzZm
MmZjYjNiMzFdIE1lcmdlIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVs
L2dpdC9kYXZlbS9uZXQtbmV4dC0yLjYKZ2l0IGJpc2VjdCBiYWQgMDE5MWI2MjVjYTVhNDYyMDZk
MmZiODYyYmIwOGYzNmYyZmNiM2IzMQojIGdvb2Q6IFsxZDI0OGIyNTkzZTkyZGI2YzUxY2EwNzIz
NTk4NWE5NWM2MjVhOTNmXSBNZXJnZSBicmFuY2ggJ2Zvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtl
cm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3JvbGFuZC9pbmZpbmliYW5kCmdpdCBi
aXNlY3QgZ29vZCAxZDI0OGIyNTkzZTkyZGI2YzUxY2EwNzIzNTk4NWE5NWM2MjVhOTNmCiMgYmFk
OiBbN2QzNTlkYWFmZTEyYjM2YjZkYTdlYzYyNDdjYWRkZjUzNDE4M2FlZF0gYXBuZTogY29udmVy
dCB0byBuZXRfZGV2aWNlX29wcwpnaXQgYmlzZWN0IGJhZCA3ZDM1OWRhYWZlMTJiMzZiNmRhN2Vj
NjI0N2NhZGRmNTM0MTgzYWVkCiMgYmFkOiBbMGE4ODhmZDFmNjMyMGQxZDkzMThjNThkZTliY2Ez
Y2VmNDE1NDZkNl0gdmlydGlvX25ldDogUmVjeWNsZSBzb21lIG1vcmUgcnggYnVmZmVyIHBhZ2Vz
CmdpdCBiaXNlY3QgYmFkIDBhODg4ZmQxZjYzMjBkMWQ5MzE4YzU4ZGU5YmNhM2NlZjQxNTQ2ZDYK
IyBnb29kOiBbYzM1NGUxMjQ2MzQ4ZTI1YzcxNGU2YjI5NzNmMzI1NzE4M2QwNmUyY10gbmV0OiBj
bGVhbiB1cCBuZXQvaXB2NC9pcG1yLmMKZ2l0IGJpc2VjdCBnb29kIGMzNTRlMTI0NjM0OGUyNWM3
MTRlNmIyOTczZjMyNTcxODNkMDZlMmMKIyBnb29kOiBbZjIxZjIzN2NmNTU0OTRjM2E0MjA5ZGUz
MjMyODFhM2IwNTI4ZGExMF0gTWVyZ2UgYnJhbmNoICd0aW1lcnMtZml4ZXMtZm9yLWxpbnVzJyBv
ZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvdGlwL2xpbnV4
LTIuNi10aXAKZ2l0IGJpc2VjdCBnb29kIGYyMWYyMzdjZjU1NDk0YzNhNDIwOWRlMzIzMjgxYTNi
MDUyOGRhMTAKIyBiYWQ6IFswNWExZTJkMTExYzk4MzQwZmIxN2VjNzAyY2YwOTQ1MGVlYzNhOTQ3
XSBhdGg5azogRW5hYmxlIGludGVycnVwdHMgYXQgdGhlIHByb3BlciBwbGFjZQpnaXQgYmlzZWN0
IGJhZCAwNWExZTJkMTExYzk4MzQwZmIxN2VjNzAyY2YwOTQ1MGVlYzNhOTQ3CiMgZ29vZDogWzRi
YWIwZWExZDQyZGQxOTI3YWY5ZGY2ZmJmMDAwM2ZjMDA2MTdjNTBdIE1lcmdlIGdpdDovL2dpdC5r
ZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9kYXZlbS9uZXQtMi42CmdpdCBiaXNl
Y3QgZ29vZCA0YmFiMGVhMWQ0MmRkMTkyN2FmOWRmNmZiZjAwMDNmYzAwNjE3YzUwCiMgZ29vZDog
WzBhOTVmNTYzMjNjZTkzZGFjMzU0YzFiMmQ1NGJmOTU5YTk4NWNmN2RdIHNmYzogQ2xlYW4gdXAg
bm9uLXZvbGF0aWxlIG1lbW9yeSBwYXJ0aXRpb25pbmcKZ2l0IGJpc2VjdCBnb29kIDBhOTVmNTYz
MjNjZTkzZGFjMzU0YzFiMmQ1NGJmOTU5YTk4NWNmN2QKIyBnb29kOiBbMTIzOWNkNThkMjM3ZmE2
YWQ1MDFhY2FlYzg3NzYyNjJhNTc4NGVjOF0gd2lyZWxlc3M6IG1vdmUgbWVzaCBjb25maWcgbGVu
Z3RoIGNvbnN0YW50CmdpdCBiaXNlY3QgZ29vZCAxMjM5Y2Q1OGQyMzdmYTZhZDUwMWFjYWVjODc3
NjI2MmE1Nzg0ZWM4CiMgYmFkOiBbMTc2ODNjNjVjOGE1ZjNmMjlmNTQwODMzNDk5Mjk4NmI5OTZk
ODIwNV0gYXRoNWs6IGZpeCBrZXl0YWJsZSB0eXBlIGJ1Z2xldCBpbiBhdGg1a19od19yZXNldF9r
ZXkKZ2l0IGJpc2VjdCBiYWQgMTc2ODNjNjVjOGE1ZjNmMjlmNTQwODMzNDk5Mjk4NmI5OTZkODIw
NQojIGJhZDogWzcxYzExZmI1N2I5MjRjMTYwMjk3Y2NkOWUxNzYxZGI1OThkMDBhYzJdIGI0My9s
ZWdhY3k6IHJlbW92ZSBTU0lEIGNvZGUKZ2l0IGJpc2VjdCBiYWQgNzFjMTFmYjU3YjkyNGMxNjAy
OTdjY2Q5ZTE3NjFkYjU5OGQwMGFjMgojIGdvb2Q6IFs0MzBjZmU5NWE0MDFiYWEwZGMyMDIyZGVh
YWQwMmNiNzVkNjNjNzNjXSBpd2wzOTQ1OiByZW1vdmUgZGVhZCBjb2RlCmdpdCBiaXNlY3QgZ29v
ZCA0MzBjZmU5NWE0MDFiYWEwZGMyMDIyZGVhYWQwMmNiNzVkNjNjNzNjCg==
--00504502ccc3e05c4f04653c5d96--
