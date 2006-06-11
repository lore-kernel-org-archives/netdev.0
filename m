From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC ] [1 of 4] IEEE802.11 Regulatory/Geographical Support for
 drivers - statement of project
Date: Sun, 11 Jun 2006 11:46:07 -0500
Message-ID: <448C48CF.50205@lwfinger.net>
References: <448210EF.10103@lwfinger.net> <20060611100750.GF24167@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:244 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750722AbWFKQqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 12:46:14 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060611100750.GF24167@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uli,

Ulrich Kunitz wrote:
> Larry,
> 
> I've not read your patches your detail, so I comment only on your
> description.
> 
> 
> The problem is the driver doesn't have good ideas, whether the
> device is outdoor and in which country it operates. Devices have
> some information available, but I have definitely a device
> marketed in Canada, which had an EEPROM value for ETSI as
> regulatory domain. I would expect the daemon to know, in which
> country it is and whether the device is used outdoors. Keep also
> in mind, that this information will be available from the AP at a
> later time.

I agree that once the AP is broadcasting the country code, this all gets easier. I have a problem 
similar to yours in that my interface's EEPROM supplies a code that indicates the world, which leads 
to the bcm43xx driver code setting 2.4 GHz channels 1 - 14 and then running active scans on all of 
them. Of course in the US 12, 13 and 14 are illegal and could lead to legal action if the FCC were 
monitoring outside my house.

I don't see any means for the daemon to know its country other than the driver or the user telling 
it. If such a means exists, I would like to learn of it. My current working model is to supply the 
country code from a module option when the driver is loaded.

> So there should be an explicit method to request the minimum set
> or the configuration of daemon. Later the set can be changed again
> by the AP information provided.

If the daemon is not running, if the country code is "  ", or if it doesn't match any country in the 
database, the minimum set is supplied, but the driver could call the routine again if it learned 
more about its environment.

>>   b) It then creates a new directory, '/proc/net/ieee80211_geo', and 
>>   populates it with 2 files for communication with the daemon. The first, 
>> which is read by the daemon, contains the country and outdoor codes, and 
>> the second is for the the daemon to write the 'struct ieee80211_geo' data 
>> corresponding to the country and indoor/outdoor information passed from the 
>> kernel.
> 
> Michael Buesch already commented on /proc/net. I don't think, that
> this will be popular with a lot of folks. sysfs should be
> supported and the mechanism should be comparable to firmware
> loading. Maybe this could be some kind of udev extension. And make
> it device specific, the whole approach should not break, if you
> are accessing two devices connecting to two different access
> points at the same time, where one of them is configured by the
> central networking folks, who don't bother to adapt there configs
> to specific countries and the other is a perfectly conformant
> local AP, which is used for "testing" purposes.

Based on Michael's comments, I have changed the kernel - user space communication to use sysfs 
rather than procfs. It also uses only a single mode 0666 file in /sys for communication. The deamon 
spins waiting for that file to exist, then reads it to get the country and in/out flags. It then 
writes the geo binary data to the file, closes it, delays a while and then repeats. After the geo 
data are read, the kernel routine deletes the kobjects that create the sysfs file, loads the geo 
data into the location supplied by the driver, and exits. Because the /sys file exists for only a 
short time, I don't think that having it world writable will cause any problems. In addition, the 
data supplied are thoroughly checked to make sure that it has the proper data for geo information. 
If the 0666 mode is a problem, the daemon may have to become root to write the data.

Because, the geo data is loaded into a data area that is specific to each device, I don't expect any 
problem with the situation you describe even if the same driver is operating both devices. If I have 
missed some nuance, please enlighten me.

>> 2. The user-space daemon, which need not be run as root, does the following:
> 
> It needs only to run temporarily run as root. I would definitely
> recommend that all file parsing activities should not run as root.

At present, it does everything as an unprivileged user.

>>   e) It then spins waiting for the existence of file 
>>   '/proc/net/ieee80211_geo/country', which is the indication that the kernel 
>> is requesting data.
> 
> Again the whole interface should be device specific. 

This part I don't understand. Everything in the geo data is generic to ieee802.11 devices. As I 
stated earlier, it will end up in the private data for the device, but I don't see any reason for 
the daemon to know which device is going to use the data.


Thanks for your comments,

Larry
