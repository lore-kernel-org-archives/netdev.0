From: Brad Johnson <bjohnson@ecessa.com>
Subject: How to associate xfrm policy to VTI tunnel or link?
Date: Wed, 30 Apr 2014 14:07:26 -0500
Message-ID: <536149EE.6060807@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:59570 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaD3THd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 15:07:33 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so518714igb.5
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 12:07:30 -0700 (PDT)
Received: from [192.168.2.92] ([173.160.121.97])
        by mx.google.com with ESMTPSA id nh12sm8375571igb.12.2014.04.30.12.07.29
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 12:07:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are running a gentoo distro with 3.10.26 kernel. We are using 
StrongSwan and would like to route vpn traffic through a vti type tunnel 
or link for added flexibility in routing, and also to support 
connections to Cisco vti type ipsec VPNs. I have found very little help 
around the internet regarding this subject. I found these threads in the 
netdev list:

http://www.spinics.net/lists/netdev/msg202717.html
http://www.spinics.net/lists/netdev/msg253134.html

After trying the things suggested in those threads I can't get it to work.

My setup is:
192.168.10.0/24 === 10.1.1.2 === 10.1.3.2 === 192.168.11.0/24

My ipsec.conf conn section contains:

   left=10.1.1.2
   leftsubnet=192.168.10.0/24
   right=10.1.3.2
   rightsubnet=192.168.11.0/24
   mark_out=32
   mark_in=33

Resulting in the following xfrm SA's when connected:

src 10.1.1.2 dst 10.1.3.2
     proto esp spi 0xcdc7070f reqid 1 mode tunnel
     replay-window 32 flag af-unspec
     mark 32/0xffffffff
     auth-trunc hmac(sha1) 0xd086e7528ebcbbd38101db1c354f0c0546817659 96
     enc cbc(aes) 0xb816c35c765239f0e352f02cb9fc1246
src 10.1.3.2 dst 10.1.1.2
     proto esp spi 0xc7233721 reqid 1 mode tunnel
     replay-window 32 flag af-unspec
     mark 33/0xffffffff
     auth-trunc hmac(sha1) 0x8df35a011f24ab4e0747598e3d39571700735ad4 96
     enc cbc(aes) 0x56db0a3bc88a4c3bd1bc7f72230fbb98

And the following xfrm policies:

src 192.168.11.0/24 dst 192.168.10.0/24
     dir fwd priority 1859
     mark 33/0xffffffff
     tmpl src 10.1.3.2 dst 10.1.1.2
         proto esp reqid 1 mode tunnel
src 192.168.11.0/24 dst 192.168.10.0/24
     dir in priority 1859
     mark 33/0xffffffff
     tmpl src 10.1.3.2 dst 10.1.1.2
         proto esp reqid 1 mode tunnel
src 192.168.10.0/24 dst 192.168.11.0/24
     dir out priority 1859
     mark 32/0xffffffff
     tmpl src 10.1.1.2 dst 10.1.3.2
         proto esp reqid 1 mode tunnel

In mangle table PREROUTING I add rules to set proper mark for outbound 
and inbound:
iptables -t mangle -A PREROUTING -s 192.168.10.0/24 -d 192.168.11.0/24 
-j MARK --set-mark 32
iptables -t mangle -A PREROUTING -p esp -s 10.1.3.2 -d 10.1.1.2 -j MARK 
--set-mark 33

I create a vti link like this:
ip link vti1 type vti local 10.1.1.2 remote 10.1.3.2 okey 32 ikey 33
ip link set vti1 up

And finally set a route to direct outbound to the vti link:
ip route add 192.168.11.0/24 dev vti1

The result then of pinging end to end (192.168.10.x to 192.168.11.x) is 
the ping works and is encrypted but does not go out the vti link. It 
instead goes over the regular WAN link on the box.

Any advice will be appreciated.
Regards,
Brad Johnson
