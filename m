From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH 1/2] netfilter: kill nf_send_reset6() from include/net/netfilter/ipv6/nf_reject.h
Date: Mon, 13 Oct 2014 11:41:57 -0400
Message-ID: <CA+5PVA7-k-HFGUUeZ3LTCmVcmR1h_=8W-_PzRO4-2dcc_cRHaQ@mail.gmail.com>
References: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
	<1412879261-25045-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11348eee2c710a05054fbdf2
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412879261-25045-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11348eee2c710a05054fbdf2
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Oct 9, 2014 at 2:27 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> nf_send_reset6() now resides in net/ipv6/netfilter/nf_reject_ipv6.c
>
> Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to nf_reject_ipvX modules")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/netfilter/ipv6/nf_reject.h |  157 +-------------------------------
>  1 file changed, 2 insertions(+), 155 deletions(-)

Hi All,

This morning I was testing a kernel build from Linus' tree as of Linux
v3.17-7639-g90eac7eee2f4.  When I rebooted my test machines, I
couldn't ssh back into any of them.  I poked around a bit and noticed
that it seems the iptables rules weren't getting loaded properly.
Traffic out worked fine, and I could ping the machine, but other
incoming traffic was blocked.  Then I saw that the ip6t_REJECT and
ip6t_rpfilter modules were not being loaded on the bad kernel.
Looking in dmesg I see:

[   14.619028] nf_reject_ipv6: module license 'unspecified' taints kernel.
[   14.619125] nf_reject_ipv6: Unknown symbol ip6_local_out (err 0)

So I did a git bisect and it pointed to this patch:

[jwboyer@obiwan linux]$ git bisect bad
91c1a09b33c902e20e09d9742560cc238a714de5 is the first bad commit
commit 91c1a09b33c902e20e09d9742560cc238a714de5
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Oct 7 18:48:12 2014 +0200

    netfilter: kill nf_send_reset6() from include/net/netfilter/ipv6/nf_reject.h

    nf_send_reset6() now resides in net/ipv6/netfilter/nf_reject_ipv6.c

    Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to
nf_reject_ipvX modules")
    Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Acked-by: Eric Dumazet <edumazet@google.com>

:040000 040000 ab5b61e7ba562e0b22d781a4322ed73c657878dc
71822a7e785c408dd55a6c4600144573de500512 M      include
[jwboyer@obiwan linux]$

I've attached the bisect log.

Perhaps one too many header files were trimmed in this case?

josh

--001a11348eee2c710a05054fbdf2
Content-Type: application/octet-stream; name=BISECT_LOG
Content-Disposition: attachment; filename=BISECT_LOG
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i17zn4wm0

Z2l0IGJpc2VjdCBzdGFydAojIGJhZDogWzkwZWFjN2VlZTJmNDI1NzY0NGRjZmI5ZDIyMzQ4ZmRl
ZDdjMjRhZmRdIE1lcmdlIHRhZyAnZnRyYWNldGVzdC0zLjE4JyBvZiBnaXQ6Ly9naXQua2VybmVs
Lm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvcm9zdGVkdC9saW51eC10cmFjZQpnaXQgYmlz
ZWN0IGJhZCA5MGVhYzdlZWUyZjQyNTc2NDRkY2ZiOWQyMjM0OGZkZWQ3YzI0YWZkCiMgZ29vZDog
W2M3OTgzNjBjZDE0MzgwOTBkNTFlZWFhOGU2Nzk4NWRhMTEzNjJlYmFdIE1lcmdlIGJyYW5jaCAn
Zm9yLTMuMTgnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dp
dC90ai9wZXJjcHUKZ2l0IGJpc2VjdCBnb29kIGM3OTgzNjBjZDE0MzgwOTBkNTFlZWFhOGU2Nzk4
NWRhMTEzNjJlYmEKIyBnb29kOiBbYTJjZTM1MjczYzJmMWFhMGRjZGRkODgyMjY4MWQ2NGVlNWYz
MTg1Ml0gTWVyZ2UgdGFnICdzb3VuZC0zLjE4LXJjMScgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcv
cHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3Rpd2FpL3NvdW5kCmdpdCBiaXNlY3QgZ29vZCBhMmNl
MzUyNzNjMmYxYWEwZGNkZGQ4ODIyNjgxZDY0ZWU1ZjMxODUyCiMgZ29vZDogWzkwZDBjMzc2ZjVl
ZTE5MjczMjdiMjY3ZmFmMTViZjk3MDQ3NmYwOWVdIE1lcmdlIGJyYW5jaCAnZm9yLWxpbnVzJyBv
ZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvbWFzb24vbGlu
dXgtYnRyZnMKZ2l0IGJpc2VjdCBnb29kIDkwZDBjMzc2ZjVlZTE5MjczMjdiMjY3ZmFmMTViZjk3
MDQ3NmYwOWUKIyBnb29kOiBbZDUzYmE2YjNiYmEzMzQzMmNjMzdiNzEwMWE4NmY4ZjMzOTJjNDZl
N10gY3hsOiBGaXggYWZ1X3JlYWQoKSBub3QgZG9pbmcgZmluaXNoX3dhaXQoKSBvbiBzaWduYWwg
b3Igbm9uLWJsb2NraW5nCmdpdCBiaXNlY3QgZ29vZCBkNTNiYTZiM2JiYTMzNDMyY2MzN2I3MTAx
YTg2ZjhmMzM5MmM0NmU3CiMgZ29vZDogWzA1MmRiN2VjODZkZmYyNmY3MzQwMzFjM2VmNWMyYzAz
YTk0YWYwYWZdIE1lcmdlIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVs
L2dpdC9kYXZlbS9zcGFyYwpnaXQgYmlzZWN0IGdvb2QgMDUyZGI3ZWM4NmRmZjI2ZjczNDAzMWMz
ZWY1YzJjMDNhOTRhZjBhZgojIGJhZDogWzI0MDMwNzdkNDc5OTFhODM4NTc4OTc3OWVlNWZjOTBi
MDAzZjlmYmVdIE1lcmdlIGJyYW5jaCAneGdlbmUnCmdpdCBiaXNlY3QgYmFkIDI0MDMwNzdkNDc5
OTFhODM4NTc4OTc3OWVlNWZjOTBiMDAzZjlmYmUKIyBnb29kOiBbYjcxYjEyZGNlMjAwZTQ3MDli
ZDlmNzA5ZTcxYzg0ZGNiMmNmOGE4Ml0gbmV0d29ya2luZzogZm0xMGs6IEZpeCBidWlsZCBmYWls
dXJlCmdpdCBiaXNlY3QgZ29vZCBiNzFiMTJkY2UyMDBlNDcwOWJkOWY3MDllNzFjODRkY2IyY2Y4
YTgyCiMgZ29vZDogWzQ1MTFhNGE1MGUxYTg3NTdmNzcxNjgxYzNlOTJkYmY1YTkyOGVlYWNdIE1l
cmdlIHRhZyAnbWFzdGVyLTIwMTQtMTAtMDgnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9z
Y20vbGludXgva2VybmVsL2dpdC9saW52aWxsZS93aXJlbGVzcy1uZXh0CmdpdCBiaXNlY3QgZ29v
ZCA0NTExYTRhNTBlMWE4NzU3Zjc3MTY4MWMzZTkyZGJmNWE5MjhlZWFjCiMgYmFkOiBbYjYxZDE4
OTA0ZTJhOTllZDE2YjZlOTdkNTQxOWYxZGIxOWUwOGJkMl0gTUFJTlRBSU5FUlM6IFVwZGF0ZSBB
UE0gWC1HZW5lIHNlY3Rpb24KZ2l0IGJpc2VjdCBiYWQgYjYxZDE4OTA0ZTJhOTllZDE2YjZlOTdk
NTQxOWYxZGIxOWUwOGJkMgojIGJhZDogW2YwZDFmMDRmMGEyZjY2MmI2YjYxN2UyNGQxMTVmZGRj
ZjZlZjg3MjNdIG5ldGZpbHRlcjogZml4IHdyb25nIGFyaXRobWV0aWNzIHJlZ2FyZGluZyBORlRf
UkVKRUNUX0lDTVBYX01BWApnaXQgYmlzZWN0IGJhZCBmMGQxZjA0ZjBhMmY2NjJiNmI2MTdlMjRk
MTE1ZmRkY2Y2ZWY4NzIzCiMgYmFkOiBbOTFjMWEwOWIzM2M5MDJlMjBlMDlkOTc0MjU2MGNjMjM4
YTcxNGRlNV0gbmV0ZmlsdGVyOiBraWxsIG5mX3NlbmRfcmVzZXQ2KCkgZnJvbSBpbmNsdWRlL25l
dC9uZXRmaWx0ZXIvaXB2Ni9uZl9yZWplY3QuaApnaXQgYmlzZWN0IGJhZCA5MWMxYTA5YjMzYzkw
MmUyMGUwOWQ5NzQyNTYwY2MyMzhhNzE0ZGU1CiMgZmlyc3QgYmFkIGNvbW1pdDogWzkxYzFhMDli
MzNjOTAyZTIwZTA5ZDk3NDI1NjBjYzIzOGE3MTRkZTVdIG5ldGZpbHRlcjoga2lsbCBuZl9zZW5k
X3Jlc2V0NigpIGZyb20gaW5jbHVkZS9uZXQvbmV0ZmlsdGVyL2lwdjYvbmZfcmVqZWN0LmgK
--001a11348eee2c710a05054fbdf2--
