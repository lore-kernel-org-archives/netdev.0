From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: wl1251: NVS firmware data
Date: Tue, 9 Dec 2014 06:25:59 +0100
Message-ID: <BB715185-F9EC-4FE6-8F23-79F47CE5BE04@holtmann.org>
References: <201411271506.20457@pali> <201412081747.30965@pali> <20141208205721.GA14895@kroah.com> <201412090027.46485@pali>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: =?utf-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201412090027.46485@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pali,

>> Use your own custom usermode helper for stuff like this, not
>> the firmware interface.  But use a binary sysfs file if you
>> want, that seems to make sense for it...
>> 
>> greg k-h
> 
> Patch for telling permanent mac address from userspace via sysfs 
> file was rejected for inclusion into mainline kernel.
> 
> So I do not think that now maintainers of network subsystem allow 
> it for nvs data...
> 
> https://lkml.org/lkml/2013/12/8/35

this magic sysfs that has to be written to at the right time of the boot process to make this all work is something that will not work. I does not work for WiFi and it does not work for Bluetooth. Seems the discussion come full circle now and we are back to square one.

The problem is that either the driver does not register the device with mac80211 until it gets the MAC address provided by userspace or mac80211 should get an unconfigured state. The unconfigured state is something telling userspace that the device is present, but needs a few extra configuration information before it can become useful.

For Bluetooth, I went the later route. Mainly because the missing address is such a generic problem that solving it in the core makes a lot more sense. The driver just tells the core that it has no address for this device and provides a custom callback to configure the address when provided. After that everything resumes as normal.

However userspace gets informed when an unconfigured device gets added and at boot it can just query the list of unconfigured devices, or at runtime wait to be told there is a new unconfigured device that needs its attention. And then just provide the information. Once all information are present, the devices disappears as unconfigured and shows up as configured device ready for normal operation.

https://git.kernel.org/cgit/bluetooth/bluez.git/tree/doc/mgmt-api.txt#n2006
http://permalink.gmane.org/gmane.linux.bluez.kernel/50716

Can something similar be added to cfg80211 + nl80211. It bet it can, but that is up to Johannes to decide and someone to actually do the work and implement it.

Regards

Marcel
