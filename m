From: "Carlos O'Donell" <carlos@redhat.com>
Subject: Re: [Patch net-next v2] net: sync some IP headers with glibc
Date: Fri, 06 Sep 2013 01:19:34 -0400
Message-ID: <522965E6.8010708@redhat.com>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com> <20130904.131351.1326721513428082697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, tmb@mageia.org,
        libc-alpha@sourceware.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <libc-alpha-return-42566-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <20130904.131351.1326721513428082697.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On 09/04/2013 01:13 PM, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu, 15 Aug 2013 17:28:10 +0800
> 
>> Solution:
>> =========
>>
>> - Synchronize linux's `include/uapi/linux/in6.h' 
>>   with glibc's `inet/netinet/in.h'.
>> - Synchronize glibc's `inet/netinet/in.h with linux's
>>   `include/uapi/linux/in6.h'.
>> - Allow including the headers in either other.
>> - First header included defines the structures and macros.
> 
> Applied, thanks for being so patient.  I want to spend the past few
> weeks making sure this is the right way to handle all of this and
> now I am confident that it is.

Pushed into 2.19.

If you compile glibc with old non-UAPI kernel headers then this code
never triggers and glibc continues to redefine the structures and we
have the same problem as always.

If you compile glibc with new UPAI kernel headers, but without the
kernel side patch, you fix the build issues only in one order of
inclusion i.e. linux header then glibc header. Thus previously your
application didn't compile, now it does, but without the kernel
side patch some of the constants glibc define may be missing. At that
point you need to file a bug against the kernel you are using and
request they add the missing constants (or add them yourself).

If you compile glibc with new UAPI kernel headers, and those headers
have the kernel side patch then everything works in any inclusion order
and the defined constants are the superset of those defined in both
implementations.

Note:
- It could have been possible with more added complexity to handle
  the case where the kernel headers have not been patched. I deemed
  that because the code never originally compiled that it was fine
  to continue not compiling in that intermediate state and only support
  the final state as a complete solution. Feel free to disagree.

commit 6c82a2f8d7c8e21e39237225c819f182ae438db3
Author: Carlos O'Donell <carlos@redhat.com>
Date:   Fri Sep 6 01:02:30 2013 -0400

    Coordinate IPv6 definitions for Linux and glibc
    
    This change synchronizes the glibc headers with the Linux kernel
    headers and arranges to coordinate the definition of structures
    already defined the Linux kernel UAPI headers.
    
    It is now safe to include glibc's netinet/in.h or Linux's linux/in6.h
    in any order in a userspace application and you will get the same
    ABI. The ABI is guaranteed by UAPI and glibc.

Cheers,
Carlos.
