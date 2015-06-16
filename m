From: Roman Khimov <khimov@altell.ru>
Subject: Re: [PATCH] net: fix search limit handling in skb_find_text()
Date: Tue, 16 Jun 2015 15:13:41 +0300
Message-ID: <6185418.JcpCEFvK8k@sencha>
References: <1434359518-16897-1-git-send-email-khimov@altell.ru> <1847765.0Hbie9lSro@mate.hex> <20150616104841.GA4163@salvia>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5107243.zvyfV8Xjqd"; micalg="sha1"; protocol="application/pkcs7-signature"
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Thomas Graf <tgraf@suug.ch>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150616104841.GA4163@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nextPart5107243.zvyfV8Xjqd
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 16 =D0=B8=D1=8E=
=D0=BD=D1=8F 2015 12:48:41 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=D0=
=B0=D1=82=D0=B5=D0=BB=D1=8C Pablo Neira Ayuso =D0=BD=D0=B0=D0=BF=D0=B8=D1=
=81=D0=B0=D0=BB:
> On Mon, Jun 15, 2015 at 10:37:31PM +0300, Roman Khimov wrote:
> > =D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 15 =D0=B8=D1=
=8E=D0=BD=D1=8F 2015 19:06:39 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=
=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Pablo Neira Ayuso =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB:
> > > On Mon, Jun 15, 2015 at 12:11:58PM +0300, Roman I Khimov wrote:
> > > > Suppose that we're trying to use an xt_string netfilter module =
to
> > > > match a
> > > > string in a specially crafted packet that has "a nice string" s=
tarting
> > > > at
> > > > offset 28.
> > > >=20
> > > > It could be done in iptables like this:
> > > >=20
> > > > -A some_chain -m string --string "a nice string" --algo bm --fr=
om 28
> > > > --to
> > > > 38 -j DROP
> > > >=20
> > > > And it would work as expected. Now changing that to
> > > >=20
> > > > -A some_chain -m string --string "a nice string" --algo bm --fr=
om 29
> > > > --to
> > > > 38 -j DROP
> > > >=20
> > > > breaks the match, as expected. But, if we try to make
> > > >=20
> > > > -A some_chain -m string --string "a nice string" --algo bm --fr=
om 20
> > > > --to
> > > > 28 -j DROP
> > > >=20
> > > > then it suddenly works again! So the 'to' parameter seems to be=

> > > > inclusive,
> > > > not working as an offset after which no search should be done. =
OK, now
> > > > if
> > > > we try:
> > > >=20
> > > > -A some_chain -m string --string "a nice string" --algo bm --fr=
om 28
> > > > --to
> > > > 28 -j DROP
> > >=20
> > > Can you reproduce the same behaviour with the km algo?
> >=20
> > Will try tomorrow MSK time.
>=20
> Thanks, wait for your feedback on this.

Same behaviour with kmp.

> > > That will break existing setups for people that are
> > > relying on this behaviour. This has been exposed in this way for =
long
> > > time, so we should avoid that breakage.
> >=20
> > Yes, that could be an issue, but there are other skb_find_text() us=
ages
> > and to me they suggest that the intended behaviour is to stop searc=
h at
> > 'to' offset.>=20
> > In nf_conntrack_amanda.c, for example:
> >         start =3D skb_find_text(skb, dataoff, skb->len,
> >        =20
> >                               search[SEARCH_CONNECT].ts);
> >=20
> > ...
> >=20
> >         stop =3D skb_find_text(skb, start, skb->len,
> >        =20
> >                              search[SEARCH_NEWLINE].ts);
> >=20
> > ...
> >=20
> >         stop +=3D start;
> >=20
> > ...
> >=20
> >                 off =3D skb_find_text(skb, start, stop, search[i].t=
s);
> >=20
> > First of all, nothing can ever match at skb->len, and second, it lo=
oks
> > like
> > the third usage is also expecting to search from offset 'start' to =
offset
> > 'stop', not to 'stop + 1'.
>=20
> Then, please fix the Amanda helper.
>=20
> Look, Amanda is an in-tree client of this textsearch infrastructure,
> so it's not exposed to userspace, we can fix it.
>
> But if we change the existing behaviour, users may be relying on it
> and we'll get things broken for them. Someone else will come later on=
e
> with another patch to say: "hey, --to used to be inclusive but this i=
s
> not the case anymore and it's breaking my setup".

I do understand your concerns, but fixing it this way would require cha=
nging=20
skb_seq_read() and basicaly would propagate "'to' offset included" sema=
ntics=20
(which seems a bit strange for programmers, IMO) further. And initially=
 I=20
thought that changing skb_seq_read() would be more intrusive, although =
looking=20
at all this now it looks like the only real user of upper_offset field =
in=20
ts_config struct is skb_find_text(), because other invocations of=20
skb_seq_read() from drivers/scsi/libiscsi_tcp.c and net/batman-adv/main=
.c use=20
skb->len as an upper limit.

> > em_text_match() in net/sched/em_text.c is also suspicious.
>=20
> Please, elaborate.

The way it constructs 'to' offset, I think it doesn't expect something =
to=20
match at 'to'. Although I might be wrong here.

--nextPart5107243.zvyfV8Xjqd
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIMPTCCBpAw
ggR4oAMCAQICAQMwDQYJKoZIhvcNAQEFBQAwgZYxCzAJBgNVBAYTAlJVMQswCQYDVQQIEwJOVzEM
MAoGA1UEBxMDU1BiMRQwEgYDVQQKEwtBbHRlbGwgTHRkLjEXMBUGA1UECxMOU2VjdXJpdHkgRGVw
dC4xGjAYBgNVBAMTEUFsdGVsbCBNYXN0ZXIgQ0EyMSEwHwYJKoZIhvcNAQkBFhJzZWN1cml0eUBh
bHRlbGwucnUwHhcNMTIwNjI5MTIyMTAwWhcNMjcwNjI5MTIwMDAwWjCBjzELMAkGA1UEBhMCUlUx
CzAJBgNVBAgTAk5XMQwwCgYDVQQHEwNTUGIxFDASBgNVBAoTC0FsdGVsbCBMdGQuMRcwFQYDVQQL
Ew5TZWN1cml0eSBEZXB0LjETMBEGA1UEAxMKQWx0ZWxsIENBMjEhMB8GCSqGSIb3DQEJARYSc2Vj
dXJpdHlAYWx0ZWxsLnJ1MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnilC4C9xC/OV
RqePImRL7mAG0DnSRepBJBM1SJdeDelRMRMNVq6nlqk+/pmA8quUCkJIaUiy+bQMHnlEirPuVK/2
GEMR7NtBop22YBWTd5n9Ktx+X/mQIViBC+x5AbwOqezgM2xhOIdpwxCB3N51xgIwFjRe6a7lqArg
RPOW1IRYQ2SEh0QxnE4j+Rznho3tLlVlpok3HxQLXixImOPrNudAllUgdVlaMEtnmTz8lGubenxa
l7b0sWqvIf8rnEDZWnOHwzmdm/+Rh9jL3ovtFa9bmz4R6I9bE4udnlSBb57IOQ8Y4SXzQlnOzhGf
vO1EIU4mCXBC4kAxxWM+LlZD4QIDAQABo4IB7DCCAegwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNV
HQ8BAf8EBAMCAQYwEQYJYIZIAYb4QgEBBAQDAgAHMBkGCWCGSAGG+EIBDQQMFgpBbHRlbGwgQ0Ey
MB0GA1UdDgQWBBRy22VUSPsELcg8vpMkV7ZoiNgGkzCBwwYDVR0jBIG7MIG4gBQMEQDmy8Yf6XYP
birE/JiMsgD2vaGBnKSBmTCBljELMAkGA1UEBhMCUlUxCzAJBgNVBAgTAk5XMQwwCgYDVQQHEwNT
UGIxFDASBgNVBAoTC0FsdGVsbCBMdGQuMRcwFQYDVQQLEw5TZWN1cml0eSBEZXB0LjEaMBgGA1UE
AxMRQWx0ZWxsIE1hc3RlciBDQTIxITAfBgkqhkiG9w0BCQEWEnNlY3VyaXR5QGFsdGVsbC5ydYIB
ATA8BgNVHR8ENTAzMDGgL6AthitodHRwOi8vY3Jscy5hbHRlbGwucnUvQWx0ZWxsX01hc3Rlcl9D
QTIuY3JsMHEGCCsGAQUFBwEBBGUwYzAoBggrBgEFBQcwAYYcaHR0cDovL29jc3Aub2ZmaWNlLmFs
dGVsbC5ydTA3BggrBgEFBQcwAoYraHR0cDovL2NybHMuYWx0ZWxsLnJ1L0FsdGVsbF9NYXN0ZXJf
Q0EyLmNydDANBgkqhkiG9w0BAQUFAAOCAgEAYp66/s1LChfJQFfE/ALDNDp3769XnARCuaHnIJ0J
pMMlvTN4F2+QOhxaa8ApeDbEUrcZT0SXCNmcdjUMTWOFGMMYE/bRKrCLQQpyg2Qf4xx7AZD4Fw2q
XXkQq8n2sEoZXyWnjBwYU+5mk3TzCH4quryJr0nURuessXDCSLfvWBYLbUT/prcBP4lMrexK6yWX
9jMcNJfZ9V08n+hOYGVRkvOlvUce/QsTRY+l83LBfFHrfEFUevb2NxLcwiRkOum3LJY4yLmed+6O
pvvPgeRnmGiS/Q4TQ6d8OIca6QusQR7dIhYSdBIqel2ccltyEaGeI+I+s8SHVphJmLM1hAZpVDhO
hrWDyK2VPgH29/HzY6dJg86X8fXU/iHI9vZ8H7vtZYyIr4byrhPzsTyM6sxc6nKfsCCQT1OWg93/
/xn76lACkibtnFmnul9EoPtdIwdXr8jsUkYw9Y8sdxCLpiV3Jhsxpd3NqrYJ6ewNyozJ8QVpz9ND
vMIrjVNnHJH+Bc0PIsKGkzCueMQU3wRxxSyiW2E1CeYql+bViqmmKU7NFx54FFXCzshx4u8UhJxz
IJdECzZw5XUumoPjOiayif3L44mxwrANBD3h+V92FwxWn3xYmOGDjhy4sMYYY5G/CII7nRaH0Tc9
ZFqUcuMlZx7rhkmZhtPCBqx+Qu4l3/cHQiAwggWlMIIEjaADAgECAgE2MA0GCSqGSIb3DQEBBQUA
MIGPMQswCQYDVQQGEwJSVTELMAkGA1UECBMCTlcxDDAKBgNVBAcTA1NQYjEUMBIGA1UEChMLQWx0
ZWxsIEx0ZC4xFzAVBgNVBAsTDlNlY3VyaXR5IERlcHQuMRMwEQYDVQQDEwpBbHRlbGwgQ0EyMSEw
HwYJKoZIhvcNAQkBFhJzZWN1cml0eUBhbHRlbGwucnUwHhcNMTIwNzMwMDg1NTAwWhcNMjIwNzMw
MDg1NTAwWjCBkjELMAkGA1UEBhMCUlUxCzAJBgNVBAgTAk5XMQwwCgYDVQQHEwNTUGIxFDASBgNV
BAoTC0FsdGVsbCBMdGQuMRowGAYDVQQLExFEZXZlbG9wbWVudCBEZXB0LjEVMBMGA1UEAxMMUm9t
YW4gS2hpbW92MR8wHQYJKoZIhvcNAQkBFhBraGltb3ZAYWx0ZWxsLnJ1MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA3XPlIFz/ziAuZdVAUP0esYrAlu5Sk7UJgQg6iO3/dwzEv6oZlZrT
zyawj4kOAfeVflFAp/1q/BN6jcDZNenf8r4ky/h8kPPOVYYNo7NeAQF1yB5IR6YRRPxRfsuHpkej
iJzI6zWoqFsfmeBE/NycmrUpJbWY0cBp6cCDDOfxoXlLGFBWlhVY1miCDeKU7vsxIKh8VVgRpQ8t
qeEZItAwMx284jgiOVlPdsmiAYUxmt+3/dSVsaU++bYnNWLd190MxCrL6NQdN5Hkhfb6tH5fgji4
BTt+Xt2vfMFyq6XXlUG5DlCbpLKi0BZum6F9157UIpHRbrRfKHb/aDC3rdV5dQIDAQABo4ICBTCC
AgEwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCBPAwKQYDVR0lBCIwIAYIKwYBBQUHAwIGCCsG
AQUFBwMEBgorBgEEAYI3FAICMDUGA1UdHwQuMCwwKqAooCaGJGh0dHA6Ly9jcmxzLmFsdGVsbC5y
dS9BbHRlbGxfQ0EyLmNybDBqBggrBgEFBQcBAQReMFwwKAYIKwYBBQUHMAGGHGh0dHA6Ly9vY3Nw
Lm9mZmljZS5hbHRlbGwucnUwMAYIKwYBBQUHMAKGJGh0dHA6Ly9jcmxzLmFsdGVsbC5ydS9BbHRl
bGxfQ0EyLmNydDARBglghkgBhvhCAQEEBAMCBaAwGwYJYIZIAYb4QgENBA4WDFJvbWFuIEtoaW1v
djAdBgNVHQ4EFgQUMjX4TmZYAF3fqJ7TOmMLQVN7XvIwgcMGA1UdIwSBuzCBuIAUcttlVEj7BC3I
PL6TJFe2aIjYBpOhgZykgZkwgZYxCzAJBgNVBAYTAlJVMQswCQYDVQQIEwJOVzEMMAoGA1UEBxMD
U1BiMRQwEgYDVQQKEwtBbHRlbGwgTHRkLjEXMBUGA1UECxMOU2VjdXJpdHkgRGVwdC4xGjAYBgNV
BAMTEUFsdGVsbCBNYXN0ZXIgQ0EyMSEwHwYJKoZIhvcNAQkBFhJzZWN1cml0eUBhbHRlbGwucnWC
AQMwDQYJKoZIhvcNAQEFBQADggEBACu7ReCTW8egyQF5vVRiTB6s840pRvmAU0A6XHkc2ONWcqbo
4bcmeaU20ShOVWrggKkbgzmcHsMw8R9D7qLp9g+zCvK6lc7Th2HZfgNvt37AJEfGqBULFzDaqkkf
BfYBXo2FgbndI9zIt66UTbkdmvfhr5kW0Apg8y2AshBfj09S8s0G0GiBt3JotgEgtIwEyIgehT2a
/JwImBXWAxyaxkBXBiP5yr955hZdItCEovOJIOJZwpK1UIcv8kh5po60LoPNwW7IuLzKpIWdCUsT
Nb96Fg7N+PMLHMt12zZIcukqjbeQnLKto6jw7jUKeu+Wpbge1S6JBG7Zdzspqg4w1/4xggJHMIIC
QwIBATCBlTCBjzELMAkGA1UEBhMCUlUxCzAJBgNVBAgTAk5XMQwwCgYDVQQHEwNTUGIxFDASBgNV
BAoTC0FsdGVsbCBMdGQuMRcwFQYDVQQLEw5TZWN1cml0eSBEZXB0LjETMBEGA1UEAxMKQWx0ZWxs
IENBMjEhMB8GCSqGSIb3DQEJARYSc2VjdXJpdHlAYWx0ZWxsLnJ1AgE2MAkGBSsOAwIaBQCggYcw
GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwNjE2MTIxMzQxWjAj
BgkqhkiG9w0BCQQxFgQUEGQ5MvRZqa72ddXFwduRMnoCV3IwKAYJKoZIhvcNAQkPMRswGTALBglg
hkgBZQMEAQIwCgYIKoZIhvcNAwcwDQYJKoZIhvcNAQEBBQAEggEAHMGa+L5yDCtJ0zidotzxceCE
S/2thFVgz5dUvPHZ8wBqSkaALsAIsPBSZRTTHf3VHNDatHm/9klzmhw4ZwIOjHynLAUW6a5iO3MO
1aWwdfrDZxdc2CTLTtrubFwYDm+i08Ew3LG7rNZrz3xq4pfi4gkeXz86zFK09957xew5HdwRAww4
Gm7dW5Crxpjd7z2Vrwiq7h4SqzJl690FgwXLgsZHVgdnuSOKhk8aH/V2ffTq8HSlq7Ft+quffz8M
1W1bt5RREztpy+A3dbBwNm4ByecCh9OacBdkyHza/z2Ke1ww3tbITaGT2RZTW1A0bLKkvatai3Qj
2XmvPGpDtj2hDgAAAAAAAA==

--nextPart5107243.zvyfV8Xjqd--

