From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/4] ipv4: fix problems with same IPs in many subnets
Date: Sat, 19 Mar 2011 01:12:00 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103190058260.1678@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-926305179-1300489920=:1678"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41157 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757492Ab1CRXGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 19:06:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-926305179-1300489920=:1678
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII


 	Here are some changes for the IPv4 addresses and
the routes we delete for setups using same primary or
secondary IPs in many subnets on device. They are made for
net-next from March 13.

 	Attached is a test script that tests the kernel
for the observed problems and validates some operations.
The same script should be available here:

http://www.ssi.bg/~ja/test_ipdel.sh

 	Can be run before and after patching to compare results.

 	Usage:

# Tune script: device, etc

# Run test with generating sorted listings, useful for diff -u
./test_ipdel.sh list > out1

# Run test with brief output
./test_ipdel.sh

 	As there some questions on using same IPs in
different subnets, here is some info and the current
problems I'm seeing.

 	__inet_insert_ifa() considers IPs as secondary when
they use same prefixlen (mask) as existing primary IP. So, it is
perfectly valid for some device:

- to have two primary IFAs for same IP "P1" but with different
masks "M1" and "M2", probably with different scope (visibility
for the defined subnet):
 	IFA1: P1/M1
 	IFA2: P1/M2

- when adding secondary IPs the same rule applies:
 	IFA3: S1/M1, can use primary P1 from IFA1
 	IFA4: S1/M2, can use primary P1 from IFA2

 	inet_ifa_byprefix() can correctly match IFA1 or IFA2
by address (P1) and mask (M1 or M2).

 	To summarize for IPs: the combination of device, IP address
and prefixlen (mask) should be unique. Same IPs can be used
in many overlapping subnets. The IPs for device are always
saved in sorted form: all primaries before all secondaries, the
primaries are sorted by decreasing scope, primaries with
same scope are in order of adding, the secondaries are in
random (adding) order but with same scope as their primary.

 	When addresses are converted to local or
broadcast routes we have:

- All routes are added with prefsrc. The prefsrc is the primary
address. As the combination of local IP and its primary address
is unique only for its subnet if we use the same IPs in another
subnet it is possible to try to add the same routes twice
resulting in duplication. But only one route is created in such case
and on deletion we should be careful not to delete routes that
are also required for the same IPs in different subnet.

- When creating local or broadcast route for the added address we
ignore the prefixlen. As result, the combination of address
(FIB node=IP/32), primary IP (fib_prefsrc) and device (fib_info, NH)
should be unique. The above IFA1 and IFA2 will try to create same
local route:

local P1/32 via dev DEV ... src P1

 	and the result will be single route.

 	IFA3 and IFA4 will add single route too:

local S1/32 via dev DEV ... src P1

 	When addresses are deleted we should remove exactly the
routes that were created for our IFA but with checks for
duplication in another subnet.

 	The problems in current code:

- fib_del_ifaddr() unconditionally tries to remove the subnet
route when deleting primary IFA. The problem is that if
prefixlen is 32 we need more checks, eg. if this IP is
still used in another subnet.

- fib_del_ifaddr() forgets to match the primary address for
every IFA that is checked. As result, routes for deleted
secondary IFAs can remain until their primary IFA is deleted
just because the same address is used in another subnet
but with different primary IP.

- fib_table_delete() does not match the prefsrc, so if there
are many routes that differ in prefsrc, always the first
route is deleted. By this way, we can not remove the right
route for the deleted IFAs.

- On secondary address promotion, when deleting the primary
address all routes with such prefsrc are currently expected to
be deleted by fib_sync_down_addr without sending events for
the remaining secondaries. But as fib_sync_down_addr calling
depends on other subnets and even on other devices we can leak
the routes.

 	The following patches fix the above problems.
I don't try to forbid same IPs to be used in multiple
subnets because it is perfectly valid subnets to overlap.

 	As patch 2 needs to know the primary IP (but not its IFA)
for every secondary address, another implementation is possible
where new field ifa_primary can cache the primary IP used
for the IFA. Then we will avoid the inet_ifa_byprefix calls
when we walk secondaries from different subnets.

 	For now I'm using a 'same_prefsrc' flag that detects if
multiple subnets use same primary IP, so such lookups are
avoided later for the secondaries for the common case when
same IPs are not used in more than one subnet.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-926305179-1300489920=:1678
Content-Type: APPLICATION/x-sh; name=test_ipdel.sh
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.LFD.2.00.1103190112000.1678@ja.ssi.bg>
Content-Description: test_ipdel.sh
Content-Disposition: attachment; filename=test_ipdel.sh

IyEgL2Jpbi9zaAojICQxOgojCSJsaXN0IjogbGlzdCByb3V0ZXMgYWZ0ZXIg
c29tZSBzdGVwcyB0byBjb21wYXJlIHRoZSBvdXRwdXQKIwkiZmx1c2giOiBy
ZXNldCBkZXZpY2UKCmxpc3Q9IiQxIgoKZGV2PSJldGgxIgppcD0iaXAiCgoj
IFJlc2V0IGRldmljZQpmdW5jdGlvbiByZXNldF9kZXYoKSB7CgllY2hvIFJF
U0VUCiAgICAgICAgJGlwIGxpbmsgc2V0ICRkZXYgdXAKICAgICAgICAkaXAg
YWRkciBmbHVzaCAkZGV2CgkkaXAgcm91dGUgZmx1c2ggZGV2ICRkZXYKCWlm
Y29uZmlnICRkZXYgMC4wLjAuMCB1cAoJZWNobyAwID4gL3Byb2Mvc3lzL25l
dC9pcHY0L2NvbmYvJGRldi9wcm9tb3RlX3NlY29uZGFyaWVzCn0KCmlmIFsg
IiQxIiA9ICJmbHVzaCIgXQp0aGVuCglyZXNldF9kZXYKCWV4aXQgMApmaQoK
IyBMaXN0IHNvcnRlZCByb3V0ZXMgZm9yIGxhdGVyIGRpZmYgLXUKZnVuY3Rp
b24gbGlzdF9yb3V0ZXMoKSB7CglbICIkbGlzdCIgIT0gImxpc3QiIF0gJiYg
cmV0dXJuIDAKCSRpcCByb3V0ZSBsaXN0IHRhYmxlIGxvY2FsIHwgZ3JlcCAt
dyAkZGV2IHwgc29ydAp9CgojIFNob3cgYWRkcmVzc2VzCmZ1bmN0aW9uIHNo
b3dfYWRkcnMoKSB7CgkkaXAgYWRkciBzaG93IGRldiAkZGV2IHwgZ3JlcCBz
Y29wZQp9CgojICQqOiBjb21tYW5kCmZ1bmN0aW9uIGNtZCgpIHsKICAgIGVj
aG8gIiQqIgogICAgJEAKfQoKIyBQZXJmb3JtIHRlc3QgZm9yIGNvdW50IG9m
IHJvdXRlcyBpbiBsb2NhbCB0YWJsZQojICQxOiBUZXN0IG5hbWUKIyAkMjog
RXhwZWN0ZWQgcm91dGUgY291bnQKIyAkMzogdHlwZSBhbmQgYWRkcmVzcyB0
byBtYXRjaCwgZWcuICJsb2NhbCAxLjIuMy40IgojICQ0OiBwcmVmc3JjIHRv
IG1hdGNoLCBhZGRyZXNzCmZ1bmN0aW9uIHRlc3Rfcm91dGUoKSB7Cglsb2Nh
bCBjb3VudD0iYCRpcCByb3V0ZSBsaXN0IHRhYmxlIGxvY2FsIHwgXAoJCWdy
ZXAgLXcgIiQzIiB8IGdyZXAgInNyYyAkNCIgfCBncmVwIC13ICIkZGV2IiB8
IHdjIC1sYCIKCWxvY2FsIHJlc3VsdD0iUEFTU0VEIgoKCVsgIiRjb3VudCIg
LW5lICIkMiIgXSAmJiByZXN1bHQ9IkZBSUxFRCIKCWVjaG8gIiRyZXN1bHQ6
ICQxIgp9CgojIFRlc3QgMTogQ2FuIHdlIGRlbGV0ZSByb3V0ZXMgYnkgZXhh
Y3QgcHJlZnNyYwojIENhbiBiZSBkZXRlY3RlZCBvbmx5IHdoZW4gZmliX2Rl
bF9pZmFkZHIgaXMgZml4ZWQgdG8gZGVsZXRlCiMgcm91dGVzIGJ5IGlnbm9y
aW5nIElGQXMgd2l0aCBkaWZmZXJlbnQgcHJpbWFyeSBJUC4gT2xkIGtlcm5l
bHMKIyBkbyBub3QgdHJ5IHRvIGRlbGV0ZSB0aGUgcm91dGVzIGlmIHNhbWUg
YWRkcmVzc2VzIGFyZSBmb3VuZAojIGZvciBkaWZmZXJlbnQgcHJpbWFyeSBJ
UHMuCmVjaG8gVEVTVCAxCnJlc2V0X2RldgoKIyBDcmVhdGUgZmlyc3QgcHJp
bWFyeQpjbWQgJGlwIGFkZHIgYWRkIDEuMi4zLjQvMjQgYnJkICsgZGV2ICRk
ZXYKbGlzdF9yb3V0ZXMKIyBDcmVhdGUgc2Vjb25kIHByaW1hcnkKY21kICRp
cCBhZGRyIGFkZCAxLjIuMy41LzI1IGJyZCArIGRldiAkZGV2Cmxpc3Rfcm91
dGVzCiMgQWRkIHRoZSBzZWNvbmQgcHJpbWFyeSBhcyBzZWNvbmRhcnkgaW4g
dGhlIGZpcnN0IHN1Ym5ldApjbWQgJGlwIGFkZHIgYWRkIDEuMi4zLjUvMjQg
YnJkICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKIyBhbmQgZGVsZXRlIHRoZW0g
aW4gcmV2ZXJzZSBvcmRlcgpjbWQgJGlwIGFkZHIgZGVsIDEuMi4zLjUvMjQg
YnJkICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKdGVzdF9yb3V0ZSAiTXVzdCBk
ZWxldGUgcm91dGUgYnkgcHJlZnNyYyIgMCAibG9jYWwgMS4yLjMuNSIgIjEu
Mi4zLjQiCmNtZCAkaXAgYWRkciBkZWwgMS4yLjMuNS8yNSBicmQgKyBkZXYg
JGRldgpsaXN0X3JvdXRlcwoKCiMgVGVzdCAyOiBDYW4gd2UgZGVsZXRlIGxv
Y2FsIHJvdXRlcyB3aGVuIHByb21vdGluZyBzZWNvbmRhcmllcwojIGFuZCB3
aGVuIGRlbGV0ZWQgYWRkcmVzcyBpcyBhbHNvIHNlY29uZGFyeSBpbiBhbm90
aGVyIHN1Ym5ldAplY2hvIFRFU1QgMgpyZXNldF9kZXYKZWNobyAxID4gL3By
b2Mvc3lzL25ldC9pcHY0L2NvbmYvJGRldi9wcm9tb3RlX3NlY29uZGFyaWVz
CgojIENyZWF0ZSBmaXJzdCBwcmltYXJ5CmNtZCAkaXAgYWRkciBhZGQgMS4y
LjMuNC8yNCBicmQgKyBkZXYgJGRldgpsaXN0X3JvdXRlcwojIENyZWF0ZSBh
bm90aGVyIHN1Ym5ldApjbWQgJGlwIGFkZHIgYWRkIDEuMi4zLjkvMjUgYnJk
ICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKIyBBZGQgdGhlIGFkZHJlc3MgdG8g
YmUgZGVsZXRlZCBhcyBzZWNvbmRhcnkgaW4gMm5kIHN1Ym5ldCBvciBvbiBh
bm90aGVyIGRldmljZQpjbWQgJGlwIGFkZHIgYWRkIDEuMi4zLjQvMjUgYnJk
ICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKIyBBZGQgc2Vjb25kYXJ5IHRvIGJl
IHByb21vdGVkIGFzIHByaW1hcnkKY21kICRpcCBhZGRyIGFkZCAxLjIuMy41
LzI0IGJyZCArIGRldiAkZGV2Cmxpc3Rfcm91dGVzCiMgQWRkIGFub3RoZXIg
c2Vjb25kYXJ5CmNtZCAkaXAgYWRkciBhZGQgMS4yLjMuNi8yNCBicmQgKyBk
ZXYgJGRldgpsaXN0X3JvdXRlcwpzaG93X2FkZHJzCiMgRGVsZXRlIHByaW1h
cnkKY21kICRpcCBhZGRyIGRlbCAxLjIuMy40LzI0IGJyZCArIGRldiAkZGV2
Cmxpc3Rfcm91dGVzCnRlc3Rfcm91dGUgIk11c3QgZGVsZXRlIGxvY2FsIHJv
dXRlIGV2ZW4gaWYgSVAgaXMgaW4gYW5vdGhlciBzdWJuZXQiIDAgImxvY2Fs
IDEuMi4zLjUiICIxLjIuMy40IgpzaG93X2FkZHJzCgojIFRlc3QgMzogTWFr
ZSBzdXJlIHdlIGRvIG5vdCBkZWxldGUgbG9jYWwgcm91dGVzIHdoZW4gcHJv
bW90aW5nIHNlY29uZGFyaWVzCiMgaWYgdGhlIGRlbGV0ZWQgcHJpbWFyeSBp
cyBhIHByaW1hcnkgaW4gYW5vdGhlciBzdWJuZXQuIFRoaXMgaXMganVzdAoj
IGZvciB2YWxpZGF0aW9uLCBub3QgdG8gc2hvdyBhbnkgcHJvYmxlbXMuCmVj
aG8gVEVTVCAzCnJlc2V0X2RldgplY2hvIDEgPiAvcHJvYy9zeXMvbmV0L2lw
djQvY29uZi8kZGV2L3Byb21vdGVfc2Vjb25kYXJpZXMKCiMgQ3JlYXRlIGZp
cnN0IHByaW1hcnkKY21kICRpcCBhZGRyIGFkZCAxLjIuMy40LzI0IGJyZCAr
IGRldiAkZGV2Cmxpc3Rfcm91dGVzCiMgQWRkIHRoZSBhZGRyZXNzIHRvIGJl
IGRlbGV0ZWQgYXMgcHJpbWFyeSBpbiAybmQgc3VibmV0CmNtZCAkaXAgYWRk
ciBhZGQgMS4yLjMuNC8yNSBicmQgKyBkZXYgJGRldgpsaXN0X3JvdXRlcwoj
IEV4dHJhIElQcyBpbiAybmQgc3VibmV0CmNtZCAkaXAgYWRkciBhZGQgMS4y
LjMuNS8yNSBicmQgKyBkZXYgJGRldgpsaXN0X3JvdXRlcwojIEFkZCBzZWNv
bmRhcnkgdG8gYmUgcHJvbW90ZWQgYXMgcHJpbWFyeQpjbWQgJGlwIGFkZHIg
YWRkIDEuMi4zLjUvMjQgYnJkICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKIyBB
ZGQgYW5vdGhlciBzZWNvbmRhcnkKY21kICRpcCBhZGRyIGFkZCAxLjIuMy42
LzI0IGJyZCArIGRldiAkZGV2Cmxpc3Rfcm91dGVzCnNob3dfYWRkcnMKIyBE
ZWxldGUgcHJpbWFyeQpjbWQgJGlwIGFkZHIgZGVsIDEuMi4zLjQvMjQgYnJk
ICsgZGV2ICRkZXYKbGlzdF9yb3V0ZXMKdGVzdF9yb3V0ZSAiTXVzdCBub3Qg
ZGVsZXRlIGxvY2FsIHJvdXRlIGlmIHNhbWUgSVAgaXMgcHJpbWFyeSBpbiBh
bm90aGVyIHN1Ym5ldCIgMSAibG9jYWwgMS4yLjMuNCIgIjEuMi4zLjQiCnNo
b3dfYWRkcnMKCg==

---1463811672-926305179-1300489920=:1678--
