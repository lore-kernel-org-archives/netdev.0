From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: RE: [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Fri, 18 Jan 2008 17:28:41 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C279A908@zin33exm24.fsl.freescale.net>
References: <FBA61160C48B8D438F3323FEFB4EF2C259F2F6@zin33exm24.fsl.freescale.net> <FBA61160C48B8D438F3323FEFB4EF2C26E7653@zin33exm24.fsl.freescale.net> <20080114120051.3207043b.kim.phillips@freescale.com> <20080114131530.9d33f50a.akpm@linux-foundation.org> <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Phillips Kim" <Kim.Phillips@freescale.com>,
	<sfr@canb.auug.org.au>, <rubini@vision.unipv.it>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>,
	"Suresh PV" <pala@freescale.com>
To: "Kumar Gala" <galak@kernel.crashing.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63260 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbYARL7f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:59:35 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All

The TDM driver just now does not have a proper framework. Probably the
interface cannot be generalised as such. Hence we could not decide
whether it would be right to think of a TDM framework. Infact the
interface this TDM driver(for MPC8323ERDB) supplies may not be usable
for some other client as such. Please suggest on this.

But you are right as far as Freescale PowerPC platforms are concerned
which have TDM devices. Like, 8315 also has a TDM driver which also
exposes similar interface as 8323 because the client it is talking to is
the same.

Following is the small description of the TDM driver along with
interface details:

The dts file keeps a track of the TDM devices present on the board.
Depending on them the TDM driver initializes those many driver instances
while coming up.

The driver on the upper level can plug to more than one tdm clients
depending on the availablity  of TDM devices. At every new request of
the TDM client to bind with a TDM device, a free driver  instance is
allocated to the client.

The interface can be described as follows.

tdm_register_client(struct tdm_client *)
	This API returns a pointer to the structure tdm_client which is
of type
	struct tdm_client {
                u32 driver_handle;
                u32 (*tdm_read)(u32 driver_handle, short chn_id, short
*pcm_buffer, short len);
                u32 (*tdm_write)(u32 driver_handle, short chn_id, short
*pcm_buffer, short len);
                wait_queue_head_t *wakeup_event;
        }

   It consists of:
   - driver_handle: It is basically to identify the particular TDM
device/driver instance.
   - tdm_read: It is a function pointer returned by the TDM driver to be
used to read TDM data  form a particular TDM channel.
   - tdm_write: It is a function pointer returned by the TDM driver to
be used to write TDM data  to a particular TDM channel.
   - wakeup_event: It is address of a wait_queue event on which the
client keeps on sleeping,  and the TDM driver wakes it up periodically.
The driver is configured to wake up the client  after every 10ms.

Once the TDM client gets registered to a TDM driver instance and a TDM
device, it interfaces  with the driver using tdm_read, tdm_write and
wakeup_event.

Note: The TDM driver can be used by only kernel level modules. The
driver does not expose any  file interface for User Applications. Can be
compared to the spi driver which interfaces with  the SPI clients
through some APIs.


I need your feedback on the interface details. Some changes were
suggested by Andrew for 32 bit tdm handle which I will modify.(Thanks
Andrew)

Please give your ideas about a TDM framework in the kernel and the
interface.

Waiting for your feedback.

Thanks and Regards
Poonam 
 
 

-----Original Message-----
From: Kumar Gala [mailto:galak@kernel.crashing.org] 
Sent: Tuesday, January 15, 2008 9:01 AM
To: Andrew Morton
Cc: Phillips Kim; Aggrwal Poonam; sfr@canb.auug.org.au;
rubini@vision.unipv.it; linux-ppcdev@ozlabs.kernel.org;
netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Barkowski Michael;
Kalra Ashish; Cutler Richard
Subject: Re: [PATCH 0/3] UCC TDM driver for MPC83xx platforms


On Jan 14, 2008, at 3:15 PM, Andrew Morton wrote:

> On Mon, 14 Jan 2008 12:00:51 -0600
> Kim Phillips <kim.phillips@freescale.com> wrote:
>
>> On Thu, 10 Jan 2008 21:41:20 -0700
>> "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com> wrote:
>>
>>> Hello  All
>>>
>>> I am waiting for more feedback on the patches.
>>>
>>> If there are no objections please consider them for 2.6.25.
>>>
>> if this isn't going to go through Alessandro Rubini/misc drivers, can

>> it go through the akpm/mm tree?
>>
>
> That would work.  But it might be more appropriate to go Kumar-
> >paulus->Linus.

I'm ok w/taking the arch/powerpc bits, but I"m a bit concerned about  
the driver itself.  I'm wondering if we need a TDM framework in the  
kernel.

I guess if Poonam could possibly describe how this driver is actually  
used that would be helpful.  I see we have 8315 with a discrete TDM  
block and I'm guessing 82xx/85xx based CPM parts of some form of TDM  
as well.

- k
