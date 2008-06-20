From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Fri, 20 Jun 2008 15:17:39 +0200
Message-ID: <485BADF3.10704@free.fr>
References: <200806171504.38702.bpidoux@free.fr>	<20080617.223050.266166325.davem@davemloft.net>	<485A893E.4080405@free.fr> <20080619.144621.120746379.davem@davemloft.net> <485ADFDF.1070509@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ralf@linux-mips.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <485ADFDF.1070509@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There have been in the past already some modifications of 
ax25_info_struct and the old one was renamed deprecated.

/* this will go away. Please do not export to user land */
struct ax25_info_struct_deprecated {
         unsigned int    n2, n2count;
         unsigned int    t1, t1timer;
         unsigned int    t2, t2timer;
         unsigned int    t3, t3timer;
         unsigned int    idle, idletimer;
         unsigned int    state;
         unsigned int    rcv_q, snd_q;
};

Three new items were included :

...
         unsigned int    vs, vr, va, vs_max;
         unsigned int    paclen;
         unsigned int    window;
};

At the same time  case SIOCAX25GETINFOOLD:
was added in ax25_ioctl()
and would trigger a warning message.


  /* old structure? */
                 if (cmd == SIOCAX25GETINFOOLD) {
                         static int warned = 0;
                         if (!warned) {
                                 printk(KERN_INFO "%s uses old 
SIOCAX25GETINFO\n",
                                         current->comm);
                                 warned=1;
                         }

                         if (copy_to_user(argp, &ax25_info, 
sizeof(struct ax25_info_struct_deprecated))) {
                                 res = -EFAULT;
                                 break;
                         }
                 } else {
                         if (copy_to_user(argp, &ax25_info, 
sizeof(struct ax25_info_struct))) {
                                 res = -EINVAL;
                                 break;
                         }
                 }
                 res = 0;
                 break;

Here is my question :

Can't we remove the probably quite old ax25_info_struct_deprecated 
structure, and rename the present ax25_info_struct, 
ax25_info_struct_deprecated, then create the new ax25_info_struct with 
resized timers unsigned long ?

The second solution is to declare a new structure

* new ax25 info struct */
struct ax25_info_long_timers_struct {
         unsigned int    n2, n2count;
         unsigned long   t1, t1timer;
         unsigned long   t2, t2timer;
         unsigned long   t3, t3timer;
         unsigned long   idle, idletimer;
         unsigned int    state;
         unsigned int    rcv_q, snd_q;
         unsigned int    vs, vr, va, vs_max;
         unsigned int    paclen;
         unsigned int    window;
};

adding another case SIOCAX25GETNEWINFO
that would be defined
#define SIOCAX25GETNEWINFO         (SIOCPROTOPRIVATE+14)

and trigger warning message by calls to SIOCAX25GETINFOOLD and
SIOCAX25GETINFO.

It that the right way to do it ?


Bernard, f6bvp



Bernard Pidoux wrote:
> David,
> 
> Your explanation is perfectly clear and I understand the problem now.
> Thank you very much for taking the time to explain me that.
> 
> Bernard Pidoux
> 
> 
> 
> 
> David Miller wrote:
>> From: Bernard Pidoux <bpidoux@free.fr>
>> Date: Thu, 19 Jun 2008 18:28:46 +0200
>>
>>> Unfortunately I don't quite understand exactly why a structure in 
>>> user space cannot be changed.
>>
>> Because there are userland binaries already compiled out there using
>> the current structure layout.  If we change the kernel, those binaries
>> stop using a datastructure that matches what the kernel is using.
>> Such binaries will break.
>>
>> In generic, because of this, you can never change the layout of a
>> data structure exported to userland as a kernel interface.
>>
>>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
