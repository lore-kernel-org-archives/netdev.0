From: Jean-Louis Dupond <info@dupondje.be>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Wed, 24 Nov 2010 23:27:20 +0100
Message-ID: <4CED9148.9010105@dupondje.be>
References: <1244831838.9225.71.camel@HP1> <4A32CDE9.7020602@dupondje.be> <1244844106.9225.92.camel@HP1> <4A32D3DB.30703@dupondje.be> <20090624173608.GA8985@xw6200.broadcom.net> <4A453E8F.3000405@dupondje.be> <20090627022629.GA27439@xw6200.broadcom.net> <4A45ED40.4090408@dupondje.be> <20090629185038.GA29283@xw6200.broadcom.net> <4A49D8ED.5060109@dupondje.be> <20090702164212.GA8430@xw6200.broadcom.net> <4CED7110.9030801@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Christensen <davidch@broadcom.com>
To: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailling.dupie.be ([85.17.239.179]:50628 "EHLO apollo.dupie.be"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751691Ab0KXWfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 17:35:53 -0500
In-Reply-To: <4CED7110.9030801@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't do more research on the issue.

The guys @ broadcom advised me to do BIOS update, so the firmware of th=
e=20
NIC is updated.

Maby you can try that also?

Sincerely,
Jean-Louis Dupond

Op 24-11-10 21:09, Krzysztof Ol=C4=99dzki schreef:
> On 2009-07-02 18:42, Matt Carlson wrote:
>> On Tue, Jun 30, 2009 at 02:20:45AM -0700, Jean-Louis Dupond wrote:
>>> # ethtool -i eth0
>>> driver: tg3
>>> version: 3.97
>>> firmware-version: 5722-v3.08, ASFIPMI v6.02
>>> bus-info: 0000:01:00.0
>>>
>>> Kernel version 2.6.29.4
>>
>> Rats. I mirrored your setup here, but I still can't reproduce the
>> problem. I still suspect this is a bad driver<=3D> firmware interact=
ion.
>>
>> Can you apply the following patch and show me the resulting syslog
>> entries? The patch is just making sure the firmware request to shutd=
own
>> really goes through.
>>
>>
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index 46a3f86..900e28b 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -1124,6 +1124,9 @@ static void tg3_wait_for_event_ack(struct tg3 =
*tp)
>> break;
>> udelay(8);
>> }
>> +
>> + if (i =3D=3D delay_cnt)
>> + printk( KERN_WARNING "Firmware didn't ack driver event!\n" );
>> }
>>
>> /* tp->lock is held. */
>> @@ -6330,12 +6333,16 @@ static void tg3_stop_fw(struct tg3 *tp)
>> /* Wait for RX cpu to ACK the previous event. */
>> tg3_wait_for_event_ack(tp);
>>
>> + printk( KERN_NOTICE "%s: Stopping firmware.\n", tp->dev->name );
>> +
>> tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_PAUSE_FW);
>>
>> tg3_generate_fw_event(tp);
>>
>> /* Wait for RX cpu to ACK this event. */
>> tg3_wait_for_event_ack(tp);
>> +
>> + printk( KERN_NOTICE "%s: Operation completed.\n", tp->dev->name );
>> }
>> }
>>
>> @@ -7537,6 +7544,8 @@ static void tg3_timer(unsigned long __opaque)
>> !(tp->tg3_flags3& TG3_FLG3_ENABLE_APE)) {
>> tg3_wait_for_event_ack(tp);
>>
>> + printk( KERN_NOTICE "%s: Sending keepalive event.\n", tp->dev->nam=
e );
>> +
>> tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX,
>> FWCMD_NICDRV_ALIVE3);
>> tg3_write_mem(tp, NIC_SRAM_FW_CMD_LEN_MBOX, 4);
>
> Hello,
>
> Have you been able to solve this issue? I have a similar problem with
> Dell PowerEdge R300 servers connected to HP2610 100Mbps switches. The
> servers contain two BCM5722 NICs and after a reboot, with probability
> about 70%, I end up with 10Mbps HD mainly on the first NIC.
>
> I discovered that it is enough to run:
> /sbin/mii-tool -R eth0
> /sbin/mii-tool -R eth1
> to trigger renegotiation that brings expected 100Mbps FD. For now, I
> added this to my startups scripts as a workaround.
>
> This problem exists in 2.6.30-stable, 2.6.31-stable and 2.6.34-stable
> which I'm currently running.
>
> Best regards,
>
> Krzysztof Ol=C4=99dzki
