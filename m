From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Fri, 26 Feb 2010 09:52:14 -0500
Message-ID: <4B87E01E.4070704@windriver.com>
References: <4B6C2488.3060403@ge.com> <4B865176.7080806@ge.com> <4B86A97E.6050509@ge.com> <20100225165141.GA9686@oksana.dev.rtsoft.ru> <20100225174935.GA32370@oksana.dev.rtsoft.ru> <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com> <20100226031452.GA11319@oksana.dev.rtsoft.ru> <4B87B937.6010204@ge.com> <20100226143532.GA31622@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Martyn Welch <martyn.welch@ge.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48958 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964913Ab0BZOwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 09:52:36 -0500
In-Reply-To: <20100226143532.GA31622@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-02-26 09:35 AM, Anton Vorontsov wrote:
> On Fri, Feb 26, 2010 at 12:06:15PM +0000, Martyn Welch wrote:
>> Anton Vorontsov wrote:
>>> On Thu, Feb 25, 2010 at 07:53:30PM -0500, Paul Gortmaker wrote:
>>> [...]
>>>
>>>> I was able to reproduce it on an 8641D and bisected it down to this:
>>>>
>>>> -----------
>>>> commit a3bc1f11e9b867a4f49505ecac486a33af248b2e
>>>> Author: Anton Vorontsov<avorontsov@ru.mvista.com>
>>>> Date:   Tue Nov 10 14:11:10 2009 +0000
>>>>
>>>>      gianfar: Revive SKB recycling
>>>>
>>>
>>> Thanks for the bisect. I have a guess why tx hangs in
>>> SMP case. Could anyone try the patch down below?
>>>
>>
>> Yup, no problem. I'm afraid it doesn't resolve the problem for me.
> 
> Hm.. I found a p2020 board and I was able to reproduce the issue.
> The patch down below fixed it completely for me... hm.

Interesting. I just tested the patch on the sbc8641d, and it
still has the issue with your patch applied.  I'm using NFSroot
just like Martyn was and it still appears bound up on that
gianfar tx lock.  I'll see if I can get a SysRq backtrace in
case that will help you see how it manages to get there...

Paul.

----

nfs: server not responding, still trying 

[repeated ~15 times, then...]
                      
INFO: task rc.sysinit:837 blocked for more than 120 seconds.                    
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.       
rc.sysinit    D 0fef73f4     0   837    836 0x00000000                          
Call Trace:                                                                     
[dfb7d9b0] [c000a144] __switch_to+0x8c/0xf8                                     
[dfb7d9d0] [c03443dc] schedule+0x380/0x954                                      
[dfb7da50] [c0344a0c] io_schedule+0x5c/0x90                                     
[dfb7da70] [c0074b0c] sync_page+0x4c/0x74                                       
[dfb7da80] [c0344f44] __wait_on_bit_lock+0xb0/0x148                             
[dfb7dab0] [c0074a8c] __lock_page+0x94/0xa4                                     
[dfb7dae0] [c0074d5c] find_lock_page+0x8c/0xa4                                  
[dfb7db00] [c0075674] filemap_fault+0x1ec/0x4fc                                 
[dfb7db40] [c008d548] __do_fault+0x98/0x53c                                     
[dfb7dba0] [c0018478] do_page_fault+0x2d0/0x500                                 
[dfb7dc50] [c00149d4] handle_page_fault+0xc/0x80                                
--- Exception: 301 at __clear_user+0x14/0x7c                                    
    LR = load_elf_binary+0x670/0x1270                                           
[dfb7dd10] [c00f6ca0] load_elf_binary+0x620/0x1270 (unreliable)                 
[dfb7dd90] [c00b1f78] search_binary_handler+0x17c/0x394                         
[dfb7dde0] [c00f4f50] load_script+0x274/0x288                                   
[dfb7de90] [c00b1f78] search_binary_handler+0x17c/0x394                         
[dfb7dee0] [c00b3580] do_execve+0x240/0x29c                                     
[dfb7df20] [c000a46c] sys_execve+0x68/0xa4                                      
[dfb7df40] [c00145a4] ret_from_syscall+0x0/0x38     

