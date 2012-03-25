From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm) slaves
Date: Sun, 25 Mar 2012 11:43:50 +0100
Message-ID: <1332672230.32446.160.camel@shinybook.infradead.org>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-IauOfyar7VUNQFbhbnTt"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47236 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab2CYKnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 06:43:55 -0400
In-Reply-To: <20120322.230331.1623101647193498167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IauOfyar7VUNQFbhbnTt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-03-22 at 23:03 -0400, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 22 Mar 2012 21:03:38 +0000
>=20
> > teql_dequeue() will *always* give up a skb when it's called, if there i=
s
> > one. If there's *not*, and the tx queue becomes empty, then the device
> > for which teql_dequeue() was called is 'promoted' to the front of the
> > line (master->slaves). That device will receive the next packet that
> > comes in, even if there are other devices which are *also* idle and
> > waiting for packets. Whenever a new packet comes in, the *last* device
> > to call teql_dequeue() gets it.
>=20
> The teql master ->ndo_start_xmit() method is where the slave iteration
> occurs, and it occurs on every successful transmit of a single packet.

Thanks for the response.

I'd seen this in teql_master_xmit(), and it works *perfectly*, *if* we
let it do its job.

The only problem here is that the PPP code is greedily sucking up all
the packets it can, calling skb_dequeue() in a loop and not letting the
*other* device(s) get any of the packets. Even when it *doesn't* get a
packet because it's emptied the queue, it gets bumped to the front of
the slaves list again, so it'll get the *next* one!

Is it that behaviour which makes you say PPP is effectively a virtual
device for this purpose? I wonder if I should just *fix* that instead,
so that it behaves as like a real device.

It's a bad idea to have huge hidden queues (a whole wmem_default worth
of packets are in a hidden queue between ppp_generic and the ATM device,
ffs!) anyway, so perhaps if we just fix *that* within PPP, it should
work a bit better with TEQL?

The other odd thing that PPP does is call skb_dequeue, attempt to feed a
packet into the low-level driver, and then *requeue* the skb if that
fails. Which it *will* do, a lot of the time. So perhaps the PPP
low-level driver could have a method call to *ask* if it's able to
accept a new packet, to avoid that dequeue-and-requeue behaviour in
ppp_generic? I'll experiment with that.

> But this cannot, and is documented not to, work when device stacking
> is involved.
>=20
> If you're dealing with (what amounts to) virtual devices, you cannot
> use TEQL and must use something like drivers/net/eql.c

I'd looked briefly at eql.c. I eventually found eql-1.2.tar.gz... with a
timestamp from a few months before I first encountered Linux in 1995, a
ZMAGIC binary in the tarball, and source code which probably hasn't
compiled for a decade... so then I figured I'd try TEQL a bit more
first :)

Having fixed up the userspace, eql.c *does* work OK =E2=80=94 but it seems =
to be
fairly unloved, and mostly duplicates the functionality of TEQL. The
fact that it forgets its slaves when you take it down and up is a bit of
a PITA too. I think I'd be happier getting TEQL working.

--=20
dwmw2

--=-IauOfyar7VUNQFbhbnTt
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIITvzCCBi0w
ggQVoAMCAQICAwCtOTANBgkqhkiG9w0BAQUFADBUMRQwEgYDVQQKEwtDQWNlcnQgSW5jLjEeMBwG
A1UECxMVaHR0cDovL3d3dy5DQWNlcnQub3JnMRwwGgYDVQQDExNDQWNlcnQgQ2xhc3MgMyBSb290
MB4XDTEwMDYxMjEwMDMwMFoXDTEyMDYxMTEwMDMwMFowgegxGDAWBgNVBAMTD0RhdmlkIFdvb2Ro
b3VzZTEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzEfMB0GCSqGSIb3DQEJARYQ
ZGF2aWRAd29vZGhvdS5zZTEoMCYGCSqGSIb3DQEJARYZZGF2aWQud29vZGhvdXNlQGludGVsLmNv
bTEkMCIGCSqGSIb3DQEJARYVZHdtdzJAbGludXguaW50ZWwuY29tMTcwNQYJKoZIhvcNAQkBFigx
MDg3MmEwN2Y2ZDdlMWUwN2Y1NWZmMTcyYTAzYjMwMGVlYWFkMjAzMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA29OPhNvMxBMW83psWdVhZDtmJvgN+tBEp1r6MZamONsR0k81a6fDFwJz
M0fEzEbV/bDG102QyX/xXC/0IpKV4acnqESC+sTHUmRwxfRKGNmR6t2iwEs2Y5kQDF31JxbCt49w
AlhLMAa+e1MBZ7vO0uDmRuJpS7+ZdHboq7cdk6dyoeumGv5sl6U/SPK9rL4KzULtqQaw6Wucd6MJ
irIggEHfCNqeT5a+TyuH4zKCwv9nblIGXq9wt+yqu5t/RicGaKPnXSqo/WpJAGggaO8g92mnYlVl
Wu/b9bYVISwQ8LI0sEtjN1WnP5AQO2f59bdPAVk4Rn25HceOO4NvlG47LwIDAQABo4IBcTCCAW0w
DAYDVR0TAQH/BAIwADBWBglghkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRl
IGZvciBGUkVFIGhlYWQgb3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcwQAYDVR0lBDkwNwYI
KwYBBQUHAwQGCCsGAQUFBwMCBgorBgEEAYI3CgMEBgorBgEEAYI3CgMDBglghkgBhvhCBAEwMgYI
KwYBBQUHAQEEJjAkMCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5jYWNlcnQub3JnMIGOBgNVHREE
gYYwgYOBE2R3bXcyQGluZnJhZGVhZC5vcmeBEGRhdmlkQHdvb2Rob3Uuc2WBGWRhdmlkLndvb2Ro
b3VzZUBpbnRlbC5jb22BFWR3bXcyQGxpbnV4LmludGVsLmNvbYEoMTA4NzJhMDdmNmQ3ZTFlMDdm
NTVmZjE3MmEwM2IzMDBlZWFhZDIwMzANBgkqhkiG9w0BAQUFAAOCAgEAXm+SUO1/TSeGJK0D9pAm
E9LTFkdlgbaD6HXGbS0TNUDyfLFkacc2F1JLoWcoFwcL6Rup5o/Rt4QYDBPWgF9EXFvqsc9SLrSe
X6VwRj7vI40x19ThE2A1Y8DzBJ9+2MzIR6hd5n9axATCOIRhmZVjX1cRkwshEGvAn8mTYGhWttkx
WhBcaAuCd9OOQqUwfxTUXiSfVumPUNrrbuvaH6MjrNjDrXdvicL26Y+AzFSJn3o8DShjjMhkUx9l
qV46BpjSGIuvkHhcLkGJ3Y1YmtOX1hwT+Z+d/10WJh8ZG2FqIlJtPtqvHK5ol/KvdzMwmMBd4qFj
YAO32vf7zde+jdTHNp2Mb15bJHhNdGOsZicpGue42fg3deZQFe1E2KBl9VO09fjncjt9YdhCUtxO
buDnoOixY6YSJgSmGJB2Xs+TE5gps4UiiOYen+NeJkuwg5x9vmyraU061Uc0csfc/E5IoxhTX/Pc
H+zXiER8aSjA/9MXQfrJM2xkY6UNKlDbCYSLKnH/O02eu7Hma6lB4wtcY8ECu7LJuFY2448Quolv
SQfQLRvKauGFGUAhbPClOxObuv/fNzA+lfg8DX2y5jXDutnpvBGgsplKxoah01SZfR9zNqxodPx2
srKhujBNB+WiAZntMf0xp4e0JPMlTFxm3tbY9wuBSyTJyueO9hUkbN4wggYtMIIEFaADAgECAgMA
rTkwDQYJKoZIhvcNAQEFBQAwVDEUMBIGA1UEChMLQ0FjZXJ0IEluYy4xHjAcBgNVBAsTFWh0dHA6
Ly93d3cuQ0FjZXJ0Lm9yZzEcMBoGA1UEAxMTQ0FjZXJ0IENsYXNzIDMgUm9vdDAeFw0xMDA2MTIx
MDAzMDBaFw0xMjA2MTExMDAzMDBaMIHoMRgwFgYDVQQDEw9EYXZpZCBXb29kaG91c2UxIjAgBgkq
hkiG9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcxHzAdBgkqhkiG9w0BCQEWEGRhdmlkQHdvb2Ro
b3Uuc2UxKDAmBgkqhkiG9w0BCQEWGWRhdmlkLndvb2Rob3VzZUBpbnRlbC5jb20xJDAiBgkqhkiG
9w0BCQEWFWR3bXcyQGxpbnV4LmludGVsLmNvbTE3MDUGCSqGSIb3DQEJARYoMTA4NzJhMDdmNmQ3
ZTFlMDdmNTVmZjE3MmEwM2IzMDBlZWFhZDIwMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBANvTj4TbzMQTFvN6bFnVYWQ7Zib4DfrQRKda+jGWpjjbEdJPNWunwxcCczNHxMxG1f2wxtdN
kMl/8Vwv9CKSleGnJ6hEgvrEx1JkcMX0ShjZkerdosBLNmOZEAxd9ScWwrePcAJYSzAGvntTAWe7
ztLg5kbiaUu/mXR26Ku3HZOncqHrphr+bJelP0jyvay+Cs1C7akGsOlrnHejCYqyIIBB3wjank+W
vk8rh+MygsL/Z25SBl6vcLfsqrubf0YnBmij510qqP1qSQBoIGjvIPdpp2JVZVrv2/W2FSEsEPCy
NLBLYzdVpz+QEDtn+fW3TwFZOEZ9uR3HjjuDb5RuOy8CAwEAAaOCAXEwggFtMAwGA1UdEwEB/wQC
MAAwVgYJYIZIAYb4QgENBEkWR1RvIGdldCB5b3VyIG93biBjZXJ0aWZpY2F0ZSBmb3IgRlJFRSBo
ZWFkIG92ZXIgdG8gaHR0cDovL3d3dy5DQWNlcnQub3JnMEAGA1UdJQQ5MDcGCCsGAQUFBwMEBggr
BgEFBQcDAgYKKwYBBAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4QgQBMDIGCCsGAQUFBwEBBCYw
JDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9yZzCBjgYDVR0RBIGGMIGDgRNkd213
MkBpbmZyYWRlYWQub3JngRBkYXZpZEB3b29kaG91LnNlgRlkYXZpZC53b29kaG91c2VAaW50ZWwu
Y29tgRVkd213MkBsaW51eC5pbnRlbC5jb22BKDEwODcyYTA3ZjZkN2UxZTA3ZjU1ZmYxNzJhMDNi
MzAwZWVhYWQyMDMwDQYJKoZIhvcNAQEFBQADggIBAF5vklDtf00nhiStA/aQJhPS0xZHZYG2g+h1
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
AAAAAA==


--=-IauOfyar7VUNQFbhbnTt--
