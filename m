From: jamal <hadi@cyberus.ca>
Subject: Re: A bug in the Kernel?
Date: 11 Mar 2005 07:31:37 -0500
Message-ID: <1110544296.1091.155.camel@jzny.localdomain>
References: <1047.80.249.146.228.1110540470.squirrel@mx.imec.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: itkes@fat.imec.msu.ru
In-Reply-To: <1047.80.249.146.228.1110540470.squirrel@mx.imec.msu.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Alex,

I didnt pay close attention to your patch, but i dont see how a problem
such as you describe can be solved by a patch in the kernel that is not
coordinated to user space.

The best way to do it is to have read/write locking of tables issued
from user (you can use ideas like the NLM_F_ATOMIC flag to signal this).
Unfortunately this means during the lock period (especially if it  is a
write lock), incoming/outgoing traffic cannot be processed.
My belief is this is a design/tradeoff decision made by Alexey to allow
this "hole" so that we dont have moments where we have freezes".

One way to do it is to have your app A also register to listen to events
that are happening in the kernel.
This way when app B deletes those routes it is informed about it.

cheers,
jamal

On Fri, 2005-03-11 at 06:27, itkes@fat.imec.msu.ru wrote:
> Hello.
> 
> I think, I have found a bug in the Linux Kernel. It is caused by working
> with lists by indexes in such operstions as routing tables dump and
> routing rules dump (functions fib_rules_dump in fib_rules.c and a few dump
> functions in fib_hash.c). If some elements are removed form the list, the
> index may identify not the element it identified earlier. As a result,
> there may happen that an application that requested the routes or rules
> dump, will not receive the entire table. There is how
> to make an application to lose some rules.
> 
> 1. Add 150 rules to kernel table.
> 2. Application A sends an RTM_GETRULE message with flag NLM_F_DUMP. The
> kernel puts first 107 rules to the buffer.
> 3. Application B deletes first 20 rules.
> 4. Application A receives the first couple of data from kernel. The kernel
> puts next couple of rules to the buffer, begining from 108-th rule, that
> was 128-th earlier.
> As a result, 20 rules had not been sent to the application, without being
> deleted or modified during the dump operation.
> 
> Routes can be lost, too, if you add certain 5000 routes, request their
> dump and remove 1000 from them during the dump.
> 
> In the patch (against kernel 2.6.11) attached, I have corrected these
> bugs. In the modified kernel, both dumps of routes and routing rules seems
> to work properly. But, I think, there can be other bugs similar to this in
> other dump operations.
> 
> Alex Itkes.
