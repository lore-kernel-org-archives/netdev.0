From: Ben Greear <greearb@candelatech.com>
Subject: Re: An interface goes away while a socket is bound to it..what happens?
Date: Tue, 18 Jan 2005 13:18:16 -0800
Message-ID: <41ED7D18.30506@candelatech.com>
References: <41EC825B.4030603@candelatech.com> <20050117193945.3d3b1860.davem@davemloft.net> <41ECB05B.8060207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41ECB05B.8060207@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> David S. Miller wrote:
> 
>> On Mon, 17 Jan 2005 19:28:27 -0800
>> Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>>> The interesting part to me is that I do not appearantly see any errors
>>> while continuing to send UDP packets on the socket that was bound to the
>>> original ppp0 interface, and yet no packets are ever routed over the new
>>> ppp0 interface.  I would expect it to either fail the write, or to just
>>> magically keep working.
>>
>>
>>
>> If you have bound to the local IP address, when your T1 goes down
>> that local IP address should no longer be assosciated with the
>> system even when the PPP interface comes back up, so what should
>> happen is that the route lookup in udp_sendmsg() will fail and sendmsg()
>> will return with that error code.
> 
> 
> Well, the new interface will come back with the same name, and same IP.
> 
> Also, I bind to the local interface with BIND_TO_DEVICE.  I can imagine
> how that might confuse things...
> 
> I will do some double-checking to make sure I'm not missing an error
> code on the sendmsg call...

I've done some more checking.  The call to sendto is returning the number
of bytes I tried to write, ie no errors.  The (new) ppp0 interface is showing
no increase in tx or rx packets.

I groped the kernel, and and so far my conjecture of how things are working
is this:

When I BINDTODEVICE, the kernel socket struct saves the interface id.  It
uses this for it's routing tricks from here on out.

When the old ppp0 device goes away, and the new one comes
back, the device-index is different.  This means, as far as I can tell, that
udp_sendmsg should return -ENODEV.

What it actually seems to do is to start generating traffic out of eth0
(which holds the default route).  I guess one could argue that if the
bound-to device does not actually exist, then we might as well send
the packet to the default gateway.  But, that could also be considered
a security risk if indeed you are using BINDTODEVICE to make sure
traffic goes out a specific interface...


Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
