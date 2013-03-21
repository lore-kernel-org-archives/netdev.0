From: Frank Rowand <frank.rowand@am.sony.com>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Thu, 21 Mar 2013 13:25:19 -0700
Message-ID: <514B6CAF.3090406@am.sony.com>
References: <514A7E81.9000501@am.sony.com> <CACVXFVODZNuoLYSk60YwhFhEv5SX2QkszjjoYDWBHij7zwmhdQ@mail.gmail.com>
Reply-To: <frank.rowand@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Rowand, Frank" <Frank_Rowand@sonyusa.com>,
	"stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"balbi@ti.com" <balbi@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"steve.glendinning@smsc.com" <steve.glendinning@smsc.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVXFVODZNuoLYSk60YwhFhEv5SX2QkszjjoYDWBHij7zwmhdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/13 02:00, Ming Lei wrote:
> Hi Frank,
> 
> On Thu, Mar 21, 2013 at 11:29 AM, Frank Rowand <frank.rowand@am.sony.com> wrote:
>>
>> I found the problem on 3.6.11, but have not replicated it on 3.9-rcX
>> yet because my config fails to build on 3.9-rc1 and 3.9-rc2.  I'll try
>> to work on that issue tomorrow.
> 
> I play upstream kernel on Pandaboard A1 frequently, looks not
> see the failure problem before. Maybe the problem is config dependent.
> 
> If you may share your config file, I'd like to do the test too.

I will do a separate reply with the actual config at the point where
the bisect completed.

I create the config for each commit during the bisect with scripts
that do the equivalent of:

  make omap2plus_defconfig

  make menuconfig

    # this allows USB thumb drive
    # Device Drivers -> USB support -> EHCI HCD (USB 2.0) support
    CONFIG_USB_EHCI_HCD=y

    # ethernet device
    # Device Drivers -> Network device support -> USB Network Adapters ->
    #  Multi-purpose USB Networking Framework ->
    #  SMSC LAN95XX based USB 2.0 10/100 ethernet devices
    CONFIG_USB_NET_SMSC95XX=y


Some more random information that may be helpful....

----------
$ cat /proc/cmdline 
ip=192.168.1.85:192.168.1.1:192.168.1.1:255.255.255.0:panda nfsroot=192.168.1.1:/a/target/panda root=/dev/nfs ip=dhcp mem=463M console=ttyO2,115200n8 debug earlyprintk


----------
The percentage of boots that show the problem varies quite a bit between
the kernel versions that I tried during my bisect.  For my first attempt
at bisecting, I decided a version was good if it booted 12 times.  That
bisect failed for various reasons.  For my second attempt at bisecting,
I decided a version was good if it booted 18 times.


----------
There are some timeout messages that I am not positive are symptoms of
the problem.  With these messages, the smsc95xx driver initialization is
successful, so the ethernet device is available.  For the first bisect
attempt, I did not treat these messages as errors.  For the second bisect
attempt I treated these messages as errors.  A typical example of the
timeout message is:

  [    9.537811] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
  [   17.056701] usb 1-1.1: swapper/0 timed out on ep0out len=0/4
  [   17.062652] smsc95xx 1-1.1:1.0: eth0: Failed to write register index 0x00000108
  [   17.070343] smsc95xx 1-1.1:1.0: eth0: Failed to write ADDRL: -110
  [   17.076751] IP-Config: Failed to open eth0

  The mention of swapper is not relevent, it just happens to be the
  current process when the time out occurs.

I have only seen these timeout messages in the boot log, so they may not
be a very visible symptom.  They also _might_ be unrelated to the problem,
but my gut feel is that they are related.


----------
The problem manifests as a timeout from at least two different locations
in drivers/net/usb/smsc95xx.c:

 656 static int smsc95xx_set_mac_address(struct usbnet *dev)
 657 {
 ...
 663         ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
 664         if (ret < 0) {
 665                 netdev_warn(dev->net, "Failed to write ADDRL: %d\n", ret);
 666                 return ret;
 667         }

751 static int smsc95xx_reset(struct usbnet *dev)
 752 {
 ...
 783         write_buf = PM_CTL_PHY_RST_;
 784         ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
 785         if (ret < 0) {
 786                 netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
 787                 return ret;
 788         }

There may be additional locations.  These are just two that I captured when
debugging.  Some of the other smsc95xx_write_reg() calls in smsc95xx_reset()
are protected with checks for timeout, with up to 100 retries.  I don't know
if more checks for timeout, or longer timeout, is a solution or just an
incorrect way of papering over the real problem -- this is not an area of
expertise for me.


Thanks,

Frank
