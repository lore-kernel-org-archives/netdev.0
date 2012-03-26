From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm) slaves
Date: Mon, 26 Mar 2012 09:32:37 +0100
Message-ID: <1332750757.2379.38.camel@shinybook.infradead.org>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
	 <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-CzyZMuR+Ad1PWBRDKuWy"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56301 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab2CZIck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 04:32:40 -0400
In-Reply-To: <20120325.173635.1909319488008466320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CzyZMuR+Ad1PWBRDKuWy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-03-25 at 17:36 -0400, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Sun, 25 Mar 2012 11:43:50 +0100
>=20
> > It's a bad idea to have huge hidden queues (a whole wmem_default worth
> > of packets are in a hidden queue between ppp_generic and the ATM device=
,
> > ffs!) anyway, so perhaps if we just fix *that* within PPP, it should
> > work a bit better with TEQL?
>=20
> Yes, the ATM devices deep transmit queue is quite undesirable.

Indeed, although I don't think it's the only cause of the problem I saw.

The first thing I tried was a hack in ppoatm_assign_vcc() to set the
socket's sk_sndbuf to 4KiB. It *seemed* to work, but only while all my
debugging printks in sch_teql were being spewed at 115200 baud over the
serial port. As soon as I hit SysRq-0 and the serial port delays went
away, I was back to bursts on one line then the other.

> But I actually don't see how the problem arises yet, I need more
> details.
>
> PPP itself will always stop the queue, and return NETDEV_TX_OK on a
> transmit attempt.  It may wake the queue back up before returning if
> the downstream device (such as pppoatm) accepted the packet.

It does indeed stop the queue. I think it then wakes it right back up
again in ppp_xmit_process(), *before* returning NETDEV_TX_OK. So the
offending calls to skb_dequeue() which are putting it back to the front
of the list are going to be from the softirq trying to feed the device.

I'll confirm that, then try fixing the PPP code so it doesn't stop and
immediately restart the queue. If it only stops the queue
*conditionally*, that may well fix the problem.

> But in either case NETDEV_TX_OK is returned and this is what the teql
> master transmit sees, and this takes the code path which advances the
> slave pointer to the next device.
>=20
> Therefore the next teql master transmit should try the next device in
> the slave list, not the PPP device used in the previous call.

I instrumented everywhere that the 'next device' pointer (m->slaves) is
assigned in sch_teql. One of the printks you see below is in
teql_master_xmit(), and it's doing exactly what you say. And then
immediately afterwards you see the other printk in teql_dequeue(),
setting m->slaves right back to the original device again:

Mar 22 15:36:07 net1-173.woodhou.se kernel: [12612.673308] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:07 net1-173.woodhou.se kernel: [12612.677630] m->slaves become=
s cebca100
Mar 22 15:36:07 net1-173.woodhou.se kernel: [12613.069589] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:07 net1-173.woodhou.se kernel: [12613.073884] m->slaves become=
s cebca100
Mar 22 15:36:07 net1-173.woodhou.se kernel: [12613.113584] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:07 net1-173.woodhou.se kernel: [12613.117908] m->slaves become=
s cebca100
Mar 22 15:36:08 net1-173.woodhou.se kernel: [12614.041113] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:08 net1-173.woodhou.se kernel: [12614.045411] m->slaves become=
s cebca100
Mar 22 15:36:09 net1-173.woodhou.se kernel: [12614.258464] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:09 net1-173.woodhou.se kernel: [12614.262762] m->slaves become=
s cebca100
Mar 22 15:36:09 net1-173.woodhou.se kernel: [12614.896259] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:09 net1-173.woodhou.se kernel: [12614.900559] m->slaves become=
s cebca100
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.129265] teql xmit cebca1=
00 next cebca400
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.133599] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.137919] m->slaves become=
s cebca100
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.141673] m->slaves become=
s cebca400
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.148321] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.152623] m->slaves become=
s cebca400
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.157979] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:10 net1-173.woodhou.se kernel: [12616.162276] m->slaves become=
s cebca400
Mar 22 15:36:11 net1-173.woodhou.se kernel: [12616.172402] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:11 net1-173.woodhou.se kernel: [12616.176731] m->slaves become=
s cebca400
Mar 22 15:36:13 net1-173.woodhou.se kernel: [12618.693948] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:13 net1-173.woodhou.se kernel: [12618.698275] m->slaves become=
s cebca400
Mar 22 15:36:14 net1-173.woodhou.se kernel: [12619.263215] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:14 net1-173.woodhou.se kernel: [12619.267539] m->slaves become=
s cebca400
Mar 22 15:36:14 net1-173.woodhou.se kernel: [12619.311534] teql xmit cebca4=
00 next cebca100
Mar 22 15:36:14 net1-173.woodhou.se kernel: [12619.315828] m->slaves become=
s cebca400
Mar 22 15:36:14 net1-173.woodhou.se kernel: [12619.645580] teql xmit cebca4=
00 next cebca100

For the first few seconds it doesn't manage to send *any* packets out
the cebca400 queue. That queue gets marked as 'next', but never quite
makes it. And then it manages to flip, and for another few seconds it
sends *all* its packets out that queue, leaving the cebca100 queue idle.

--=20
dwmw2

--=-CzyZMuR+Ad1PWBRDKuWy
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


--=-CzyZMuR+Ad1PWBRDKuWy--
