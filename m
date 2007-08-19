From: Bruce Cole <bacole@gmail.com>
Subject: Re: [RFT] r8169 changes against 2.6.23-rc3
Date: Sat, 18 Aug 2007 19:41:26 -0700
Message-ID: <46C7ADD6.5080707@gmail.com>
References: <20070818100701.GA20703@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bacole@gmail.com,
	David Gundersen <gundy@iinet.net.au>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.245]:30473 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbXHSCll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 22:41:41 -0400
Received: by ag-out-0708.google.com with SMTP id 35so1219961aga
        for <netdev@vger.kernel.org>; Sat, 18 Aug 2007 19:41:40 -0700 (PDT)
In-Reply-To: <20070818100701.GA20703@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The latest serie of r8169 changes is available against 2.6.23-rc3 as:
> http://www.fr.zoreil.com/people/francois/misc/20070818-2.6.23-rc3-r8169-test.patch 
>
> or (tarball sits one level higher):
>
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.23-rc3/r8169-20070818/
>
> or (rebase prone branch)
>   
I applied these patches (except for the eeprom read support patch) to 
2.6.23-rc3, and it did not fix the TX performance problem.  The 
busy-wait workaround is still required to dramatically improve 
performance.  I experimented some more and found that ndelay(10) is a 
sufficient delay within the for loop, as David Gundersen suggested.  
With some diagnostic code, I can see that when there is a NPQ problem, 
the busy wait calls ndelay(10) 4 or 5 times before the NPQ bit clears, 
and meanwhile the TX queue only contains a low number of entries (2 to 5 
typically).  This is a bit surprising, I would have guessed the root 
problem related to the queue filling up. 

I was then suspicious that maybe there was an issue with TX interrupts 
not being serviced in a timely manner due to the NAPI RX support, but 
making the TX processing work without NAPI did not solve things.

I took a look at tcpdump output from both the sender&receiver and found 
that when there is a problem, the sender is apparently delaying 
transmission of packets.  TCP then retransmits, and duplicate TCP 
sequences arrive at the receiver at that later time.

So it seems that when the driver tries to queue a packet while the 
controller is busy processing the queue, the newly queued packet does 
not get noticed by the controller (until further packet activity occurs).
Perhaps there is a problem with the memory barriers when adding to the 
TX queue, but I'm a newbie on linux kernel memory barriers.

tcpdump sample follows, with the realtek interface on the sending side.  
In the sample, notice that the data at sequence #1429358 is 
retransmitted by the sender after .3 seconds, but the receiver receives 
both copies at basically the same time (delayed by approximately .3 
seconds).


Sender:

13:42:10.325958 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1414878:1416326(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.325979 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1416326:1417774(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.325999 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1417774:1419222(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326018 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1419222:1420670(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326036 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1420670:1422118(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326056 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1422118:1423566(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326076 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1423566:1425014(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326094 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1425014:1426462(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326114 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1426462:1427910(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326565 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1417774 win 2056 <nop,nop,timestamp 4346009 226653029>
13:42:10.326607 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1427910:1429358 (1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326614 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1429358:1430806(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326620 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: P 
1430806:1431325(519) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:10.326626 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1427910 win 1907 <nop,nop,timestamp 4346009 226653029>
13:42:10.366646 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1429358 win 2056 <nop,nop,timestamp 4346050 226653029>
13:42:10.652691 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1429358:1430806(1448) ack 5775 win 54 <nop,nop,timestamp 226653356 
4346050> NBT Session Packet: Session Message
13:42:10.653636 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1430806 win 2056 <nop,nop,timestamp 4346337 226653029>
13:42:10.653671 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1431325 win 2056 <nop,nop,timestamp 4346337 226653029>
13:42:10.653698 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1431325 win 2056 <nop,nop,timestamp 4346337 226653029,nop,nop,sack 1 
{1429358:1430806}>

Receiver:
13:42:11.516820 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1414878:1416326(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516841 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1416326:1417774(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516856 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1417774:1419222(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516881 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1419222:1420670(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516895 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1420670:1422118(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516923 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1422118:1423566(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516938 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1423566:1425014(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516952 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1425014:1426462(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.516975 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1426462:1427910(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.517148 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1417774 win 2056 <nop,nop,timestamp 4346009 226653029>
13:42:11.517173 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1427910 win 1907 <nop,nop,timestamp 4346009 226653029>
13:42:11.517471 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1427910:1429358(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.557260 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1429358 win 2056 <nop,nop,timestamp 4346050 226653029>
13:42:11.843655 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1429358:1430806(1448) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.843704 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: P 
1430806:1431325(519) ack 5775 win 54 <nop,nop,timestamp 226653029 
4346009> NBT Session Packet: Session Message
13:42:11.843720 IP 192.168.1.11.netbios-ssn > 192.168.1.12.60994: . 
1429358:1430806(1448) ack 5775 win 54 <nop,nop,timestamp 226653356 
4346050> NBT Session Packet: Session Message
13:42:11.844342 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1430806 win 2056 <nop,nop,timestamp 4346337 226653029>
13:42:11.844366 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1431325 win 2056 <nop,nop,timestamp 4346337 226653029>
13:42:11.844383 IP 192.168.1.12.60994 > 192.168.1.11.netbios-ssn: . ack 
1431325 win 2056 <nop,nop,timestamp 4346337 226653029,nop,nop,sack 1 
{1429358:1430806}>

