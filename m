From: "Ilya Pashkovsky" <ilya.pashkovsky@gmail.com>
Subject: [Patch] SO_REUSEADDR fix in ipv4/ipv6 (n connects + 1 listen)
Date: Wed, 15 Dec 2004 18:08:13 +0200
Message-ID: <opsi14fzvzfj3ips@sibox>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=----------4cQblArTdRJef3s7HFoYxt
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------------4cQblArTdRJef3s7HFoYxt
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
Content-Transfer-Encoding: 8bit

Hello, fellow developers.
This is a proper documentation for the reuse patch, along with
its adoption for 2.6.10rc3-mm1 patchset.

Current implementation of SO_REUSEADDR in the kernel disallows
same port binding if a listening socket is already bound to it.
This limits the options for firewall/nat piercing for applications,
and is non-standard.
The current limit was made because of the security risk
of allowing free binds to same socket. This allowed listen
call preemption and, since no unambiguous and secure fix
was not found, the option to reuse port after listen-bind
was removed. (the problem is that of multiple listeners
bound to same port. this patch does not fix it, since the
behaviour is ambiguos and not defined clearly, though maybe
a userid check along with another flag telling to allow listen
preemption (SO_REUSEPORT can be reused for this purpose) may
solve that.)

Also, SO_REUSEADDR option value is boolean, but is checked
to be more than 1 in code. This check was removed.
The way multiple listeners was removed is by disallowing
any reuse of a port with a bound listener. This is implemented
by a check in tcp_ipv4.c (and tcp_ipv4.c) in function
tcp_bind_conflict(). There's a check for any existing sockets
matching the source port and having a TCP_LISTEN state.
This check was changed to allow binding unless the new
socket is also in TCP_LISTEN state. This still disallows
multiple listeners but allows reuse of the port for
outgoing connections. This check is made/modified in both
ipv4 and ipv6 code.

Testing was done using normal workloads on 2 i386 linux
installations with normal workloads and also the netcat test.

Test with netcat (uses SO_REUSEADDR by default):
host A: nc -v -l -p 9999
host B: nc -v -l -p 9000
host A: nc -v -p 9999 host.B.ip.addr 9000
host B: nc -v host.A.ip.addr 9999

host A and B can be same host.

Testing did not reveal any problems and networking software
worked fine in both ipv4 and ipv6 networks.

Signed-off-by: Ilya Pashkovsky <ilya.pashkovsky@gmail.com>

--

-- 
  ilya
------------4cQblArTdRJef3s7HFoYxt
Content-Disposition: attachment; filename=patch-rc3-mm1-reuse
Content-Type: application/octet-stream; name=patch-rc3-mm1-reuse
Content-Transfer-Encoding: Base64

LS0tIGxpbnV4L25ldC9pcHY0L3RjcF9pcHY0LmMub3JpZwkyMDA0LTEyLTE1IDEy
OjMwOjExLjcyMzEzMzAxNiArMDIwMAorKysgbGludXgvbmV0L2lwdjQvdGNwX2lw
djQuYwkyMDA0LTEyLTE1IDEyOjMwOjMxLjIxMjE3MDIzMiArMDIwMApAQCAtNTAs
NiArNTAsOCBAQAogICoJWU9TSElGVUpJIEhpZGVha2kgQFVTQUdJIGFuZDoJU3Vw
cG9ydCBJUFY2X1Y2T05MWSBzb2NrZXQgb3B0aW9uLCB3aGljaAogICoJQWxleGV5
IEt1em5ldHNvdgkJYWxsb3cgYm90aCBJUHY0IGFuZCBJUHY2IHNvY2tldHMgdG8g
YmluZAogICoJCQkJCWEgc2luZ2xlIHBvcnQgYXQgdGhlIHNhbWUgdGltZS4KKyAq
CUlseWEgUGFzaGtvdnNreQkJOglhbGxvdyByZXVzZSBvZiBwb3J0IHdpdGggc2lu
Z2xlIGxpc3RlbmVyCisgKgkJCQkJcmVtb3ZlIGJvb2xlYW4gc2tfcmV1c2UgPiAx
IGNoZWNrCiAgKi8KIAogI2luY2x1ZGUgPGxpbnV4L2NvbmZpZy5oPgpAQCAtMTkz
LDcgKzE5NSw4IEBAIHN0YXRpYyBpbmxpbmUgaW50IHRjcF9iaW5kX2NvbmZsaWN0
KHN0cnUKIAkJICAgICAhc2syLT5za19ib3VuZF9kZXZfaWYgfHwKIAkJICAgICBz
ay0+c2tfYm91bmRfZGV2X2lmID09IHNrMi0+c2tfYm91bmRfZGV2X2lmKSkgewog
CQkJaWYgKCFyZXVzZSB8fCAhc2syLT5za19yZXVzZSB8fAotCQkJICAgIHNrMi0+
c2tfc3RhdGUgPT0gVENQX0xJU1RFTikgeworCQkJICAgIChzazItPnNrX3N0YXRl
ID09IFRDUF9MSVNURU4gJiYKKwkJCQlzay0+c2tfc3RhdGUgPT0gVENQX0xJU1RF
TikpIHsKIAkJCQljb25zdCB1MzIgc2syX3Jjdl9zYWRkciA9IHRjcF92NF9yY3Zf
c2FkZHIoc2syKTsKIAkJCQlpZiAoIXNrMl9yY3Zfc2FkZHIgfHwgIXNrX3Jjdl9z
YWRkciB8fAogCQkJCSAgICBzazJfcmN2X3NhZGRyID09IHNrX3Jjdl9zYWRkcikK
QEAgLTI1OSw4ICsyNjIsNiBAQCBzdGF0aWMgaW50IHRjcF92NF9nZXRfcG9ydChz
dHJ1Y3Qgc29jayAqCiAJZ290byB0Yl9ub3RfZm91bmQ7CiB0Yl9mb3VuZDoKIAlp
ZiAoIWhsaXN0X2VtcHR5KCZ0Yi0+b3duZXJzKSkgewotCQlpZiAoc2stPnNrX3Jl
dXNlID4gMSkKLQkJCWdvdG8gc3VjY2VzczsKIAkJaWYgKHRiLT5mYXN0cmV1c2Ug
PiAwICYmCiAJCSAgICBzay0+c2tfcmV1c2UgJiYgc2stPnNrX3N0YXRlICE9IFRD
UF9MSVNURU4pIHsKIAkJCWdvdG8gc3VjY2VzczsKLS0tIGxpbnV4L25ldC9pcHY2
L3RjcF9pcHY2LmMub3JpZwkyMDA0LTEyLTE1IDEyOjMxOjQxLjg4ODQyNTgwOCAr
MDIwMAorKysgbGludXgvbmV0L2lwdjYvdGNwX2lwdjYuYwkyMDA0LTEyLTE1IDAx
OjQyOjA4LjYwMzI2NTcyOCArMDIwMApAQCAtMTgsNiArMTgsNyBAQAogICoJQWxl
eGV5IEt1em5ldHNvdgkJYWxsb3cgYm90aCBJUHY0IGFuZCBJUHY2IHNvY2tldHMg
dG8gYmluZAogICoJCQkJCWEgc2luZ2xlIHBvcnQgYXQgdGhlIHNhbWUgdGltZS4K
ICAqCVlPU0hJRlVKSSBIaWRlYWtpIEBVU0FHSToJY29udmVydCAvcHJvYy9uZXQv
dGNwNiB0byBzZXFfZmlsZS4KKyAqCUlseWEgUGFzaGtvdnNreQkJOglhbGxvdyBy
ZXVzZSBvZiBwb3J0IHdpdGggc2luZ2xlIGxpc3RlbmVyCiAgKgogICoJVGhpcyBw
cm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0
IGFuZC9vcgogICogICAgICBtb2RpZnkgaXQgdW5kZXIgdGhlIHRlcm1zIG9mIHRo
ZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZQpAQCAtMTExLDcgKzExMiw4IEBA
IHN0YXRpYyBpbmxpbmUgaW50IHRjcF92Nl9iaW5kX2NvbmZsaWN0KHMKIAkJICAg
ICAhc2syLT5za19ib3VuZF9kZXZfaWYgfHwKIAkJICAgICBzay0+c2tfYm91bmRf
ZGV2X2lmID09IHNrMi0+c2tfYm91bmRfZGV2X2lmKSAmJgogCQkgICAgKCFzay0+
c2tfcmV1c2UgfHwgIXNrMi0+c2tfcmV1c2UgfHwKLQkJICAgICBzazItPnNrX3N0
YXRlID09IFRDUF9MSVNURU4pICYmCisJCSAgICAgKHNrMi0+c2tfc3RhdGUgPT0g
VENQX0xJU1RFTiAmJgorCQkJc2stPnNrX3N0YXRlID09IFRDUF9MSVNURU4pKSAm
JgogCQkgICAgIGlwdjZfcmN2X3NhZGRyX2VxdWFsKHNrLCBzazIpKQogCQkJYnJl
YWs7CiAJfQo=

------------4cQblArTdRJef3s7HFoYxt--
