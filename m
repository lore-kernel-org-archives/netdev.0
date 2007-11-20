From: "Sam Jansen" <sjansen@google.com>
Subject: Problem with sysctl_tcp_congestion_control function
Date: Mon, 19 Nov 2007 16:25:16 -0800
Message-ID: <84ae20740711191625x399a3099ma29de2ee7933281e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_15893_31710300.1195518316155"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6931 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbXKTAZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 19:25:20 -0500
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id lAK0PHoV012319
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 00:25:18 GMT
Received: from nz-out-0506.google.com (nzfm22.prod.google.com [10.36.189.22])
	by zps77.corp.google.com with ESMTP id lAK0PGdN022774
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 16:25:16 -0800
Received: by nz-out-0506.google.com with SMTP id m22so1300874nzf
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 16:25:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_15893_31710300.1195518316155
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

sysctl_tcp_congestion_control seems to have a bug that prevents it from
actually calling the tcp_set_default_congestion_control function. This is not
so apparent because it does not return an error and generally the /proc
interface is used to configure the default TCP congestion control algorithm.
This is present in 2.6.18 onwards and probably earlier, though I have not
inspected 2.6.15--2.6.17.

sysctl_tcp_congestion_control calls sysctl_string and expects a successful
return code of 0. In such a case it actually sets the congestion control
algorithm with tcp_set_default_congestion_control. Otherwise, it returns the
value returned by sysctl_string. This was correct in 2.6.14, as sysctl_string
returned 0 on success. However, sysctl_string was updated to return 1 on
success around about 2.6.15 and sysctl_tcp_congestion_control was not updated.
Even though sysctl_tcp_congestion_control returns 1, do_sysctl_strategy
converts this return code to '0', so the caller never notices the error.

A sample program that shows this behaviour is attached. It is hardcoded to set
the congestion control algorithm to reno. Running it multiple times shows that
it succeeds, yet does not modify the default TCP congestion control algorithm.

e.g.,

$ make sysctl
$ sudo /tmp/sysctl; sudo /tmp/sysctl
old value='bic', new value should be='reno'
old value='bic', new value should be='reno'

A simple patch is also attached that modifies the if statement in
sysctl_tcp_congestion_control.

------=_Part_15893_31710300.1195518316155
Content-Type: text/x-csrc; name=sysctl.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f97opduq0
Content-Disposition: attachment; filename=sysctl.c

I2luY2x1ZGUgPGxpbnV4L3VuaXN0ZC5oPgojaW5jbHVkZSA8bGludXgvdHlwZXMuaD4KI2luY2x1
ZGUgPGxpbnV4L3N5c2N0bC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KCl9zeXNjYWxsMShpbnQsIF9z
eXNjdGwsIHN0cnVjdCBfX3N5c2N0bF9hcmdzICosIGFyZ3MpOwppbnQgc3lzY3RsKGludCAqbmFt
ZSwgaW50IG5sZW4sIHZvaWQgKm9sZHZhbCwgc2l6ZV90ICpvbGRsZW5wLAogICAgdm9pZCAqbmV3
dmFsLCBzaXplX3QgbmV3bGVuKQp7CiAgc3RydWN0IF9fc3lzY3RsX2FyZ3MgYXJncz17bmFtZSxu
bGVuLG9sZHZhbCxvbGRsZW5wLG5ld3ZhbCxuZXdsZW59OwogIHJldHVybiBfc3lzY3RsKCZhcmdz
KTsKfQoKI2RlZmluZSBTSVpFKHgpIHNpemVvZih4KS9zaXplb2YoeFswXSkKI2lmbmRlZiBORVRf
VENPX0NPTkdfQ09OVFJPTAojZGVmaW5lIE5FVF9UQ1BfQ09OR19DT05UUk9MIDExMAojZW5kaWYK
CmludCBtYWluKCkKewogIGNoYXIgb2xkbmFtZVsxMDBdOwogIHNpemVfdCBvbGRuYW1lbGVuID0g
U0laRShvbGRuYW1lKTsKICBjaGFyIG5ld3ZhbFtdID0gInJlbm8iOwogIHNpemVfdCBuZXd2YWxs
ZW4gPSBTSVpFKG5ld3ZhbCk7CiAgaW50IG5hbWVbXSA9IHsgQ1RMX05FVCwgTkVUX0lQVjQsIE5F
VF9UQ1BfQ09OR19DT05UUk9MIH07CgogIGlmIChzeXNjdGwobmFtZSwgU0laRShuYW1lKSwgb2xk
bmFtZSwgJm9sZG5hbWVsZW4sIG5ld3ZhbCwgbmV3dmFsbGVuKSkKICAgIHBlcnJvcigic3lzY3Rs
Iik7CiAgZWxzZQogICAgcHJpbnRmKCJvbGQgdmFsdWU9JyVzJywgbmV3IHZhbHVlIHNob3VsZCBi
ZT0nJXMnXG4iLCBvbGRuYW1lLCBuZXd2YWwpOwogIHJldHVybiAwOwp9Cgo=
------=_Part_15893_31710300.1195518316155
Content-Type: text/x-patch; name=tcp_congestion_control.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f97opjsr1
Content-Disposition: attachment; filename=tcp_congestion_control.patch

LS0tIC90bXAvbmV0L2lwdjQvc3lzY3RsX25ldF9pcHY0LmMJMjAwNy0xMC0wNSAxMTowNzoyNS4w
MDAwMDAwMDAgLTA3MDAKKysrIG5ldC9pcHY0L3N5c2N0bF9uZXRfaXB2NC5jCTIwMDctMTEtMTkg
MTY6MDU6MTYuMDAwMDAwMDAwIC0wODAwCkBAIC0xMjksNyArMTI5LDcgQEAKIAl0Y3BfZ2V0X2Rl
ZmF1bHRfY29uZ2VzdGlvbl9jb250cm9sKHZhbCk7CiAJcmV0ID0gc3lzY3RsX3N0cmluZygmdGJs
LCBuYW1lLCBubGVuLCBvbGR2YWwsIG9sZGxlbnAsIG5ld3ZhbCwgbmV3bGVuLAogCQkJICAgIGNv
bnRleHQpOwotCWlmIChyZXQgPT0gMCAmJiBuZXd2YWwgJiYgbmV3bGVuKQorCWlmIChyZXQgPT0g
MSAmJiBuZXd2YWwgJiYgbmV3bGVuKQogCQlyZXQgPSB0Y3Bfc2V0X2RlZmF1bHRfY29uZ2VzdGlv
bl9jb250cm9sKHZhbCk7CiAJcmV0dXJuIHJldDsKIH0K
------=_Part_15893_31710300.1195518316155--
