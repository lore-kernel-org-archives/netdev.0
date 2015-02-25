From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 10:53:11 +0000
Message-ID: <54EDA997.1080005@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <20150218210830.GA7778@localhost.localdomain> <54EAF4D4.4090505@linn.co.uk> <20150225095056.GB4293@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<netdev@vger.kernel.org>, <abrestic@chromium.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150225095056.GB4293@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 25/02/15 09:50, Richard Cochran wrote:
>
> The Linux kernel already fully supports this kind of application via
> the SIOCSHWTSTAMP, SO_TIMESTAMPING, and PHC mechanisms.  We certainly
> don't need another another interface just for someone's warped
> hardware design.
>
> I suggest that you find a way to make your HW work within the existing
> frame work.

The driver already uses that framework for returning timestamps to user 
space. It does not introduce any new interface.

>
>> The interface needs to be public so that a user-space application
>> can program a command string that will match packets that belong to
>> the audio stream of interest, for this example.
>
> Let the user program simply use a BPF for that.
>
>> In addition returning just a timestamp would not be enough in many
>> cases. In the audio streaming use case mentioned above some
>> additional
>> bytes from the packet payload need to be returned (with Copy
>> commands) in order to associate the timestamp with a certain point
>> in the audio stream.
>
> The time stamp is *already* associated with a particular frame.
>
> Just tell your driver to program the hardware to:
>
> 1. time stamp every frame
> 2. deliver every frame
>
> Thats all you need.
>

The H/W could not support that:
We have a "Match/Stamp" command, so the packet byte needs to match the 
value following the command, in order for a timestamp to be generated, 
otherwise the packet is dropped.
In addition, due to FIFO size limitations up to 128 bytes (including the 
timestamp) can be returned (through Copy commands) from each packet.

The module was designed to be able to configure it to sniff packets 
belonging to a certain application level stream and from each matching 
packet return a timestamp and some bytes (from eg. the application layer 
protocol header) that would be useful to the application.

BPF could accomplish that too, but timestamps will not be as accurate
without H/W support.

I understand that the device needs to be configured with a proprietary
command stream, but all interfacing with user-space is done using 
existing frameworks (AF_PACKET, SIOCSHWTSTAMP, cmsg)

>> Actually, that is how the H/W works. Each Match command is followed by
>> a data value which must match the packet data byte at the corresponding
>> location. If there is no match processing of the packet stops.
>
> And just what is the "corresponding location"?

The command string is made up of a sequence of <CMD><DATA> pairs. Take 
this for example: {0x00, 0x00, 0x01, 0x55, 0x02, 0x00, 0x04, 0x00}.
First command is Don't Care (0x00), ie 1st byte of Ethernet frame is 
just skipped.
Second command is Match (0x01), ie if the 2nd byte of the Ethernet frame 
is 0x55 processing continues otherwise packet is dropped.
Third command is Copy (0x02), ie 3rd byte of the packet is copied to the 
H/W FIFO to be returned to the user
Fourth command is Copy/Done (0x04), ie 4th packet byte is also copied to 
the FIFO and processing stops.
Then an IRQ is generated, data (2 bytes) are read from the FIFO and
delivered through an AF_PACKET socket.

In v4 of the patch I tried to improve the documentation of some of these 
points.
>
> Thanks,
> Richard
>

Thanks,
Stathis
