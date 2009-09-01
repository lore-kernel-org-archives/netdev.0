From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: r8189 mac address changes persist across reboot (was: duplicate
 MAC 	addresses)
Date: Tue, 01 Sep 2009 09:58:59 +0200
Message-ID: <4A9CD443.6030603@redhat.com>
References: <9b2b86520908230314q37d07da6mbde9dc48ad5a17ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	marty <marty@goodoldmarty.com>, linux-hotplug@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Mikael Pettersson <mikpe@it.uu.se>
To: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <9b2b86520908230314q37d07da6mbde9dc48ad5a17ce@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Jenkins napsal(a):
> On 8/23/09, marty <marty@goodoldmarty.com> wrote:
>> Greg KH wrote:
>>>> On Tue, Aug 18, 2009 at 04:27:04PM -0400, marty wrote:
>>>>>> I got trouble...
>>>>>> (duplicate MAC addresses)
>>>> That's a bug in your hardware, have you asked your manufacturer to
>>>> resolve this for you?  That violates the ethernet spec...
>> I have resolved that problem as of today. I found this was caused
>> by the software I had been using. If a hardware issue remains, it is moot.
>>
>> The bonding driver/utilities normally sets the bond address to the MAC of
>> the
>> first NIC. But it also set the MAC of the slave (eth3) to the MAC of the
>> first
>> NIC. This persists through reboots so that is how my MACs got duplicated.
>>
>> Resetting the MAC corrected those problems and everything works fine now.
>>
>> Marty B.
> 
> Hmm.  <Documentation/networking/bonding.txt>
> 
> "To restore your slaves' MAC addresses, you need to detach them
> from the bond (`ifenslave -d bond0 eth0'). The bonding driver will
> then restore the MAC addresses that the slaves had before they were
> enslaved."
> 
> In which case one would hope that a clean shutdown would restore the
> MAC addresses in the same way as ifenslave -d.
> 
> I found that snippet via Google, which pointed me to the 2.4 version
> of the same document [1].  It suggests that your hardware or driver is
> a little unusual.
> 
> "To restore your slaves' MAC addresses, you need to detach them
> from the bond (`ifenslave -d bond0 eth0'), set them down
> (`ifconfig eth0 down'), unload the drivers (`rmmod 3c59x', for
> example) and reload them to get the MAC addresses from their
> eeproms."
> 
> So other drivers would not have this problem, because they always
> reset the MAC address at load time.  That would explain why the the
> kernel doesn't bother resetting the MAC addresses on shutdown.
> 
> Looking at r8169.c confirms this.  It doesn't appear to initialize the
> MAC address register from elsewhere; it just uses the current value.
> It will also report this initial value as the "permanent" MAC address,
> which your report suggests is wrong.  I think your problem is a bug in
> r8169.
> 
> Francois, I found a datasheet for the 8139; it was claimed to be
> similar and it does indeed appear so.  The datasheet suggests that the
> driver needs to provoke "auto-load" from the EEPROM at load time.
> Could you please have a look at fixing this, so that MAC address
> changes do not persist over a reboot?
> 
Using auto-loading method is not possible for all new Realtek products
(mainly for PCI-E chipsets). I asked the Realtek engineers and this
is the answer:
Q: Is it possible to use HW register at offset 50h to reload the MAC
   address from EEPROM or somewhere else? I mean the usage of Auto-load
   mode (bits EEM1=0 and EEM0=1 in 50h HW reg).
A: Current new LANs don't load mac address throught autoload command.
   You need to read it out from external eeprom or internal efuse then
   put it back to ID0~ID5.

So you need to read the MAC address from the EEPROM and then write it into
ID0-ID5 registers. I already created the patch that initializes the MAC
address from EEPROM but there were some issues with this patch so it was
reverted. Mikael reported that the MAC address from its adapter (on Thecus
n2100) is read only partly (first 3 bytes were correct but the rest were
zeros). Later we found that the MAC address is correct and there are really
3 correct bytes + 3 zeros in EEPROM. The Thecus n2100 system probably uses
only these 3 bytes and the remaining 3 bytes fills in by itself (they are
probably stored somewhere in the firmware).

I have tested my patch with several different realtek NICs without any
problem but what should we do with embedded system like the n2100 that
initializes the MAC in other way.

There are 2 possibilities:
1) There could be an additional module param to enable/disable the MAC
   initialization
2) The MAC address read from EEPROM will be checked against the current
   MAC address in ID0-5 registers. And the current MAC will be replaced
   by the one from EEPROM only if the first 3 bytes (OUI part) are
   different.

Francois, what do you think about it?

Regards,
Ivan
