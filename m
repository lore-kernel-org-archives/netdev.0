From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: A bug in the Kernel?
Date: Fri, 18 Mar 2005 09:59:39 -0800
Message-ID: <20050318095939.5550d7bb@dxpl.pdx.osdl.net>
References: <1033.80.249.146.157.1111167862.squirrel@mx.imec.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: itkes@fat.imec.msu.ru
In-Reply-To: <1033.80.249.146.157.1111167862.squirrel@mx.imec.msu.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 20:44:22 +0300 (MSK)
itkes@fat.imec.msu.ru wrote:

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
> Alex Itkes (Moscow State University).
> 
> P.S. Sorry if you get this message twice. I have already sent it, but the
> first instance seems to be lost.

Couple of minor nits.
Incorrect indentation: 
		if (idx > s_idx)
-			memset(&cb->args[0], 0, sizeof(cb->args));
+		    NLCB_ZERO(cb,0);
                ^^^^-- should be tab

Why introduce a macro instead of the memset, it seems to just confuse the issue.
Better to make it an inline function with a name like rtnl_cb_zero(...)
