From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Subject: r8189 mac address changes persist across reboot (was: duplicate MAC
	addresses)
Date: Sun, 23 Aug 2009 11:14:38 +0100
Message-ID: <9b2b86520908230314q37d07da6mbde9dc48ad5a17ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: marty <marty@goodoldmarty.com>, linux-hotplug@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/09, marty <marty@goodoldmarty.com> wrote:
> Greg KH wrote:
>> > On Tue, Aug 18, 2009 at 04:27:04PM -0400, marty wrote:
>>> >> I got trouble...
>>> >> (duplicate MAC addresses)
>> >
>> > That's a bug in your hardware, have you asked your manufacturer to
>> > resolve this for you?  That violates the ethernet spec...
>
> I have resolved that problem as of today. I found this was caused
> by the software I had been using. If a hardware issue remains, it is moot.
>
> The bonding driver/utilities normally sets the bond address to the MAC of
> the
> first NIC. But it also set the MAC of the slave (eth3) to the MAC of the
> first
> NIC. This persists through reboots so that is how my MACs got duplicated.
>
> Resetting the MAC corrected those problems and everything works fine now.
>
> Marty B.

Hmm.  <Documentation/networking/bonding.txt>

"To restore your slaves' MAC addresses, you need to detach them
from the bond (`ifenslave -d bond0 eth0'). The bonding driver will
then restore the MAC addresses that the slaves had before they were
enslaved."

In which case one would hope that a clean shutdown would restore the
MAC addresses in the same way as ifenslave -d.

I found that snippet via Google, which pointed me to the 2.4 version
of the same document [1].  It suggests that your hardware or driver is
a little unusual.

"To restore your slaves' MAC addresses, you need to detach them
from the bond (`ifenslave -d bond0 eth0'), set them down
(`ifconfig eth0 down'), unload the drivers (`rmmod 3c59x', for
example) and reload them to get the MAC addresses from their
eeproms."

So other drivers would not have this problem, because they always
reset the MAC address at load time.  That would explain why the the
kernel doesn't bother resetting the MAC addresses on shutdown.

Looking at r8169.c confirms this.  It doesn't appear to initialize the
MAC address register from elsewhere; it just uses the current value.
It will also report this initial value as the "permanent" MAC address,
which your report suggests is wrong.  I think your problem is a bug in
r8169.

Francois, I found a datasheet for the 8139; it was claimed to be
similar and it does indeed appear so.  The datasheet suggests that the
driver needs to provoke "auto-load" from the EEPROM at load time.
Could you please have a look at fixing this, so that MAC address
changes do not persist over a reboot?

Thanks
Alan

"1. Features

Uses 93C46 (64*16-bit EEPROM) to store resource
                    configuration, ID parameter, and VPD data
...

5. Register Descriptions
The RTL8139D(L) provides the following set of operational registers
mapped into PCI memory space or I/O space.
     Offset       R/W                Tag
           Description
     0000h         R/W               IDR0            ID Register 0,
The ID register0-5 are only permitted to read/write by
                                                     4-byte access.
Read access can be byte, word, or double word access.
                                                     The initial value
is autoloaded from EEPROM EthernetID field.

...

5.9 9346CR: 93C46 Command Register
(Offset 0050h, R/W)
This register is used for issuing commands to the RTL8139D(L). These
commands are issued by setting the corresponding bits for the
function. A warm software reset along with individual reset and
enable/disable for transmitter and receiver are provided as well.

Bit R/W Symbol                          Description
7-6 R/W EEM1-0 Operating Mode: These 2 bits select the RTL8139D(L) operating
               mode.

                 EEM1    EEM0                      Operating Mode
                    0      0    Normal (RTL8139D(L) network/host communication
                                mode)
                    0      1    Auto-load: Entering this mode will make the
                                RTL8139D(L) load the contents of 93C46
like when the
                                RSTB signal is asserted. This
auto-load operation will
                                take about 2 ms. After it is
completed, the RTL8139D(L)
                                goes back to the normal mode
automatically (EEM1 =
                                EEM0 = 0) and all the other registers
are reset to default
                                values."




[1] Bonding mini-howto for 2.4 kernel
<http://www.kernel.org/pub/linux/kernel/people/marcelo/linux-2.4/Documentation/networking/bonding.txt>
