From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Thu, 22 Dec 2011 10:37:03 +0100
Message-ID: <4EF2FA3F.3010308@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com> <4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com> <4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com> <4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com> <4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com> <4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com> <4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com> <4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com> <4EE5EBBF.6080007@grandegger.com> <4EF22625.5000109@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EF22625.5000109@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 12/21/2011 07:32 PM, Wolfgang Zarre wrote:
> Hello Wolfgang,
...

>> It's a bug! netif_start_queue is missing at the end of the open
>> function. Got lost some how. I have just updated (rebased!) my
>> wg-linux-can-next repository.
> 
> Ok, I was checking out last week and since I'm running one test series
> after the other.
> 
> There are several odd issues I could found and I'm trying to trace them
> down beside some other work.
> 
> Even with an assumed correct configuration like I was using with the lincan
> driver I'm loosing telegrams so around 1 till 2 in 500000 but might be a
> different sample-point at the PLC which is opaque due the predefined
> setting.

In principle, messages can be lost because the cc770 does buffer only up
to two messages in hardware. If they are not read out quickly enough,
message loss will happen. The CAN statistics should list such overruns,
though.

> For the next test I'll set the BTR's directly.

OK, if you do not see bus errors, everything should be fine.

> Further sometimes I can find one in dropped but mostly not.
> 
> But more odd is that after an undefined time the transmission gets
> stuck followed by a buffer overrun but can receive.

I recently found a bug. Please try this fix:

http://marc.info/?l=linux-can&m=132370253713701&w=4

Did you realize related error messages in the dmesg output?

> No error messages nor changes in ip -d -s link show can0.
> 
> Additional it seems that neither the automatic restart nor
> the manual one works.

What version are you using. I think this problem has been fixed by
adding the missing netif_start_queue() at the end of the open
function, as mentioned above. Do you have that in your driver?

> ip link set can0 up type can restart gives me 'RTNETLINK answers: Invalid
> argument' and ip link set can0 up type can bitrate 500000 restart a
> RTNETLINK answers: Device or resource busy but nothing connected to can0.

The error message is shown because you try to set bitrate when the
device is up. For the restart after bus-off just type:

  # ip link set can0 type can restart

Anyway, if you run into a bus-off, then it's likely that you have
electrical problems on the CAN bus, e.g. termination, mismatching
bit-timing parameters.

> So I have to perform per example  ip link set can0 down;ip link set can0 up
> type can bitrate 500000 restart-ms 2000 sample-point 0.75
> but this is emptying the buffer and these telegrams are lost then as well.
> 
> I was comparing with my lincan driver which was running so far ok also
> to confirm a proper working PLC.
> 
> First I assumed that maybe the set_reset_mode procedure is responsible for
> that misbehaviour because according to the cc770 manual we should wait for
> a zero of bit 7 RstST of the CPU interface register but when the
> transmission
> gets stuck there was no call for set_reset_mode.
> 
> Maybe it's ending up somehow recessive.
> 
> Anyway, I might compare the registers of both drivers just to figure out
> what's going on but maybe You have an idea as well.
> 
> Problem is just it runs always quite some time until the issues happen
> otherwise it would be more easy.

Again, please check if you have netif_start_queue() at the end of the
open function.

Wolfgang.
