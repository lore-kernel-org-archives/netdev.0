From: David Oostdyk <daveo@ll.mit.edu>
Subject: Re: defxx: skb_push() failing?
Date: Tue, 26 Mar 2013 14:45:00 -0400
Message-ID: <5151ECAC.9040404@ll.mit.edu>
References: <5151B0CE.5000000@ll.mit.edu>  <1364310900.1716.21.camel@edumazet-glaptop> <5151C6C3.6090408@ll.mit.edu> <1364315410.1716.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms070108000706040606050007"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"macro@linux-mips.org" <macro@linux-mips.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:50798 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932376Ab3CZSqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 14:46:17 -0400
In-Reply-To: <1364315410.1716.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms070108000706040606050007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On 03/26/13 12:30, Eric Dumazet wrote:
> On Tue, 2013-03-26 at 12:03 -0400, David Oostdyk wrote:
>> On 03/26/13 11:15, Eric Dumazet wrote:
>>> On Tue, 2013-03-26 at 10:29 -0400, David Oostdyk wrote:
>>>> Hello,
>>>>
>>>> In dfx_xmt_queue_pkt() in defxx.c, there is a skb_push(3) call which=

>>>> makes room for 3 packet request header bytes.  There is some discuss=
ion
>>>> in the driver explaining why those three bytes will be available.  I=

>>>> have an old FDDI card that I'm trying to bring up:
>>>>
>>>> 05:05.0 FDDI network controller: Digital Equipment Corporation
>>>> PCI-to-PDQ Interface Chip [PFI] (rev 02)
>>>>
>>>> Most skbuffs that come through dfx_xmit_queue_pkt() have 11 bytes
>>>> between skb->head and skb->data.  On the other hand, at almost exact=
ly
>>>> 60-second intervals, an skb arrives that has zero bytes between
>>>> skb->head and skb->data.  This normally causes a kernel panic, and f=
or
>>>> the time I just skip over such skb's.
>>>>
>>>> Does anyone have advice on where I should start digging to find the
>>>> cause of this?
>>>>
>>> Have you read comments in defxx.c file around line 151 ?
>>>
>>> If one skb arrives with not enough headroom, you could add a
>>>
>>> WARN_ON_ONCE(skb_headroom(skb) < 3);
>>>
>>> and report stack trace so that we can identify and fix the caller.
>>>
>>>
>>>
>> I have read the comments, and alloc_fddidev() seems to set the
>> hard_header_len as described.
>>
>> As for the stack trace, thanks for the tip!  Here is the output
>> (including various defxx debug statements):
>>
>> [  350.312482] defxx: v1.10 2006/12/14  Lawrence V. Stefani and others=

>> [  350.312582] In dfx_driver_init...
>> [  350.312583] In dfx_bus_init...
>> [  350.312585] In dfx_bus_config_check...
>> [  351.699416] 0000:05:05.0: DEFPA at addr =3D 0xf9eeff80, IRQ =3D 26,=

>> Hardware addr =3D 00-60-b0-58-48-53
>> [  351.699425] 0000:05:05.0: Descriptor block virt =3D FFFF8800CB83400=
0,
>> phys =3D CB834000
>> [  351.699426] 0000:05:05.0: Command Request buffer virt =3D
>> FFFF8800CB835380, phys =3D CB835380
>> [  351.699427] 0000:05:05.0: Command Response buffer virt =3D
>> FFFF8800CB835580, phys =3D CB835580
>> [  351.699428] 0000:05:05.0: Receive buffer block virt =3D
>> FFFF8800CB835780, phys =3D CB835780
>> [  351.699429] 0000:05:05.0: Consumer block virt =3D FFFF8800CB835780,=

>> phys =3D CB835780
>> [  351.700049] 0000:05:05.0: registered as fddi0
>> [  351.756194] In dfx_open...
>> [  351.756215] In dfx_adap_init...
>> [  353.927747] fddi0: Multicast address table updated!  Added 1 addres=
ses.
>> [  353.930352] fddi0: Adapter filters updated!
>> [  353.975887] fddi0: Multicast address table updated!  Added 1 addres=
ses.
>> [  353.978492] fddi0: Adapter filters updated!
>> [  354.043455] fddi0: Multicast address table updated!  Added 2 addres=
ses.
>> [  354.046359] fddi0: Adapter filters updated!
>> [  354.097315] fddi0: Multicast address table updated!  Added 3 addres=
ses.
>> [  354.099919] fddi0: Adapter filters updated!
>> [  354.204301] fddi0: Multicast address table updated!  Added 3 addres=
ses.
>> [  354.207107] fddi0: Adapter filters updated!
>> [  354.257972] fddi0: Multicast address table updated!  Added 3 addres=
ses.
>> [  354.261577] fddi0: Adapter filters updated!
>> [  362.976038] ------------[ cut here ]------------
>> [  362.976044] WARNING: at drivers/net/fddi/defxx.c:3202
>> dfx_xmt_queue_pkt+0xa2/0x2f2 [defxx]()
>> [  362.976046] Hardware name: Precision WorkStation 490
>> [  362.976047] Modules linked in: defxx snd_hda_codec_idt snd_hda_inte=
l
>> snd_hda_codec snd_hwdep snd_pcm iTCO_wdt snd_page_alloc lpc_ich
>> snd_timer mfd_core i5000_edac rng_core i2c_i801 fddi rtc_cmos [last
>> unloaded: defxx]
>> [  362.976066] Pid: 1773, comm: aoe_tx Tainted: G          I
>> 3.7.10-hippi+ #6
>> [  362.976068] Call Trace:
>> [  362.976076]  [<ffffffff810357e7>] warn_slowpath_common+0x7e/0x96
>> [  362.976080]  [<ffffffff81035814>] warn_slowpath_null+0x15/0x17
>> [  362.976083]  [<ffffffffa0063213>] dfx_xmt_queue_pkt+0xa2/0x2f2 [def=
xx]
>> [  362.976088]  [<ffffffff813c3401>] ? map_single+0x45/0x45
>> [  362.976093]  [<ffffffff819175a8>] dev_hard_start_xmit+0x288/0x398
>> [  362.976097]  [<ffffffff81929d1c>] sch_direct_xmit+0x72/0x19b
>> [  362.976100]  [<ffffffff819179ec>] dev_queue_xmit+0x145/0x339
>> [  362.976105]  [<ffffffff8184ab20>] tx+0x1c/0x42
>> [  362.976108]  [<ffffffff818489a2>] kthread+0x5e/0xbf
>> [  362.976113]  [<ffffffff81056451>] ? try_to_wake_up+0x239/0x239
>> [  362.976116]  [<ffffffff81848944>] ? rexmit_timer+0x349/0x349
>> [  362.976119]  [<ffffffff8104c678>] kthread+0xb5/0xbd
>> [  362.976122]  [<ffffffff8104c5c3>] ? __kthread_parkme+0x67/0x67
>> [  362.976127]  [<ffffffff81a314ec>] ret_from_fork+0x7c/0xb0
>> [  362.976129]  [<ffffffff8104c5c3>] ? __kthread_parkme+0x67/0x67
>> [  362.976131] ---[ end trace ce553e95611628f3 ]---
>>
>>
>> Thanks again for any help!
> Are you really using AOE ?
>
> drivers/block/aoe/aoenet.c can apparently call dev_queue_xmit() with no=
n
> compliant skbs.
>
> Please try following patch :
>
> diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
> index 25ef5c0..92b6d7c 100644
> --- a/drivers/block/aoe/aoecmd.c
> +++ b/drivers/block/aoe/aoecmd.c
> @@ -51,8 +51,9 @@ new_skb(ulong len)
>   {
>   	struct sk_buff *skb;
>  =20
> -	skb =3D alloc_skb(len, GFP_ATOMIC);
> +	skb =3D alloc_skb(len + MAX_HEADER, GFP_ATOMIC);
>   	if (skb) {
> +		skb_reserve(skb, MAX_HEADER);
>   		skb_reset_mac_header(skb);
>   		skb_reset_network_header(skb);
>   		skb->protocol =3D __constant_htons(ETH_P_AOE);
>
>
>

Hi Eric,

This patch did remove the offending skb's.  (I'm not using AOE - not=20
intentionally, anyway - so I'm not sure why this was being called.)

(Now if I could only figure out why these FDDI cards don't want to talk=20
to each other... I was hoping that was it.)

Thanks for the help!



--------------ms070108000706040606050007
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
nLGXAtzo1mIsnwexqTEWMA4GA1UdDwEB/wQEAwIGwDAfBgNVHSMEGDAWgBSOSn2JoWMXHIGI
NFc3JkVeGYp+JDAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3JsLmxsLm1pdC5lZHUvZ2V0
Y3JsL0xMQ0EyMGIGCCsGAQUFBwEBBFYwVDAtBggrBgEFBQcwAoYhaHR0cDovL2NybC5sbC5t
aXQuZWR1L2dldHRvL0xMQ0EyMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5sbC5taXQuZWR1
LzAMBgNVHRMBAf8EAjAAMD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIOD5R2H7Kdmhq2H
FYPq8EWFtqEfHYXL3jKH/4pzAgFkAgEFMCIGA1UdJQEB/wQYMBYGCCsGAQUFBwMEBgorBgEE
AYI3CgMMMBgGA1UdIAQRMA8wDQYLKoZIhvcSAgEDAQgwGwYDVR0RBBQwEoEQZGF2ZW9AbGwu
bWl0LmVkdTANBgkqhkiG9w0BAQsFAAOCAQEAN0sDbMECUU+lLNEAK/Md5d98WfE3A2hfdJPx
VtYNv0ceHVWp5E/obqpbyEl8PuyAQ+dzjoUBHaqYLIRvssXlY7nFbM75bGsgFOWSQR03zXKw
1Ej7zd2qRS2FT+HIz02rQxpndIwKd7+bmw+gjrBZ5lwHKYAtLRMeqta1Gb9n/FLUBc65jlmt
PFNzSTroVwFq49aWzCwoCUvT4SgDjbd4JK0/I26rC8oCwetHGzTGXO+6x+rEbl6gWR1AKkg4
7sT1ChoxQ4gDh1HdeYyRt1kpZtcp7p9sD8YUkUTfM2mLN3VggTcAcUxP8Jwg7SoU9E/rImLR
gprlNC9ku6NRkHJUbTCCBNEwggO5oAMCAQICCmIFT/YAAAAAOoIwDQYJKoZIhvcNAQELBQAw
UTELMAkGA1UEBhMCVVMxHzAdBgNVBAoTFk1JVCBMaW5jb2xuIExhYm9yYXRvcnkxDDAKBgNV
BAsTA1BLSTETMBEGA1UEAxMKTUlUTEwgQ0EtMjAeFw0xMjA1MjIxNDQwNDlaFw0xMzA1MjIx
NDQwNDlaMGIxCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQgTGluY29sbiBMYWJvcmF0b3J5
MQ8wDQYDVQQLEwZQZW9wbGUxITAfBgNVBAMTGE9vc3RkeWsuRGF2aWQuSi41MDAwODgwMTCC
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
--------------ms070108000706040606050007--
