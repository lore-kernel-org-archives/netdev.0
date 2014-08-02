From: Chris Friesen <chris.friesen@windriver.com>
Subject: Re: weird behaviour, getting EAGAIN on a connect() call on a unix
 stream socket
Date: Sat, 2 Aug 2014 08:11:43 -0600
Message-ID: <53DCF19F.5030002@windriver.com>
References: <53DC6039.2010002@windriver.com> <1406960889.3178.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:49223 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbaHBOLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 10:11:49 -0400
In-Reply-To: <1406960889.3178.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2014 12:28 AM, Eric Dumazet wrote:
> On Fri, 2014-08-01 at 21:51 -0600, Chris Friesen wrote:

>> I've got an app that tries to connect() to both of them in turn.  The connect()
>> to the first socket fails with EAGAIN, the second one succeeds, and all
>> subsequent retries on the first fail.  Here's an strace() of the sequence:
>>
>> socket(PF_FILE, SOCK_STREAM, 0)         = 6
>> fcntl(6, F_GETFL)                       = 0x2 (flags O_RDWR)
>> fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
>
> Non blocking socket : If listener queue is full, -EAGAIN is expected


That doesn't make any sense though, there is only one process that ever 
attempts to connect() to this socket, and I only ran it one instance at 
a time.  That implies that the first time I got EAGAIN the queue would 
have been empty when the connection request came in.


>> With the app not running, netstat seems to show that something is trying to
>> connect to the socket in question:
>>
>> root@compute-0:~# netstat -ap unix |grep messaging
>> unix  2      [ ACC ]     STREAM     LISTENING     1109818  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> unix  2      [ ACC ]     STREAM     LISTENING     1110051  17425/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
>> unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> unix  2      [ ]         STREAM     CONNECTED     1109848  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>>
>>
>> Here's /proc/net/unix for completeness:
>>
>> root@compute-0:~/host-guest-comm# grep -a messaging /proc/net/unix
>> ffff880045c35540: 00000002 00000000 00010000 0001 01 1109818 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> ffff8800576b8a80: 00000002 00000000 00010000 0001 01 1110051 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
>> ffff880045e2f040: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> ffff88004bc5ea80: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>> ffff880045e2f540: 00000002 00000000 00000000 0001 03 1109848 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
>>
>>
>>
>> The crazy thing is that I can't figure out what could be causing the
>> CONNECTED/CONNECTING sockets.  There are no background processes of the
>> connecting app running, no zombie processes, no forked children, etc.
>>
>> Just to make things more interesting, I successfully ran this application
>> several times (connecting to both sockets) before this behaviour started
>> happening.  I was running it under strace and just killed it with ctrl-C.
>>
>> Anyone got any ideas?   Please CC me since I'm not subscribed to the list.
>
> The application might use a too small listen() backlog ?

Looking at the qemu code I think it's calling listen(sock,1) which makes 
sense since I think it's only designed to allow a single connection up 
into the guest at a time.

Not sure how that could be the problem though, since there is only one 
process that tries to connect() to the application, and I only ran it 
one instance at a time.

I'll give the patch a try, but how would that explain the sockets that 
are in a CONNECTING state when as far as I can tell they don't belong to 
any process?

Am I correct to think that the CONNECTED socket may be due to the two 
CONNECTING ones somehow?

Chris
