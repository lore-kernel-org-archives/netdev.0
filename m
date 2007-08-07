From: jamal <hadi@cyberus.ca>
Subject: Re: fscked clock sources revisited
Date: Tue, 07 Aug 2007 09:19:52 -0400
Message-ID: <1186492792.5163.94.camel@localhost>
References: <1185844239.5162.17.camel@localhost>
	 <20070730.183750.77058266.davem@davemloft.net>
	 <1185848076.5162.39.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:62932 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758810AbXHGNT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:19:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1730109wxd
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2007 06:19:56 -0700 (PDT)
In-Reply-To: <1185848076.5162.39.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-30-07 at 22:14 -0400, jamal wrote:

> I am going to test with hpet when i get the chance

Couldnt figure how to turn on/off hpet, so didnt test.

> and perhaps turn off all the other sources if nothing good comes out; i
> need my numbers ;->

Here are some numbers that make the mystery even more interesting. This
is with kernel 2.6.22-rc4. Repeating with kernel 2.6.23-rc1 didnt show
anything different. I went back to test on 2.6.22-rc4 because it is the 
base for my batching patches - and since those drove me to this test, i
wanted something that reduces variables when comparing with batching.

I picked udp for this test because i can select different packet sizes.
i used iperf. The sender is a dual opteron with tg3. The receiver is a
dual xeon.

The default HZ is 250. Each packet size was run 3 times with different
clock sources. The experiment made sure that the receiver wasnt a
bottleneck (increased socket buffer sizes etc)

Packet | jiffies (1/250) |      tsc      |    acpi_pm
-------------------------|---------------|---------------
  64   |  141, 145, 142  | 131, 136, 130 | 103, 104, 110
 128   |  256, 256, 256  | 274, 260, 269 | 216, 206, 220
 512   |  513, 513, 513  | 886, 886, 886 | 828, 814, 806
1280   |  684, 684, 684  | 951, 951, 951 | 951, 951, 951

So i was wrong to declare jiffies as being good. The last batch of
experiments were based on only 64 byte UDP. Clearly as packet size goes
up, the results are worse with jiffies.
At this point, i decided to recompile the kernel with HZ=1000 and the
observations show that the jiffies results are improved.

Packet | jiffies (1/250) |      tsc      |    acpi_pm
-------------------------|---------------|---------------
  64   |  145, 135, 135  | 131, 137, 139 | 110, 110, 108
 128   |  257, 257, 257  | 270, 264, 250 | 218, 216, 217
 512   |  819, 776, 819  | 886, 886, 886 | 841, 824, 846
1280   |  855, 855, 855  | 951, 950, 951 | 951, 951, 951

Still not as good as the other two at large packet sizes.
For this machine: The ideal clock source would be jiffies with
HZ=1000 upto about 100 bytes then change to tsc. Of course i could pick
tsc but people have dissed it so far - i probably didnt hit the
condition where it goes into deep slumber.

Any insights? This makes it hard to quantify batching experimental
improvements as i feel it could be architecture or worse machine
dependent.

cheers,
jamal 

