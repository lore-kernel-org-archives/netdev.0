From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 4/17]: Check TCA_ACT_KIND payload size _before_
 copying it
Date: Thu, 30 Dec 2004 15:20:50 +0100
Message-ID: <41D40EC2.3070906@trash.net>
References: <41D37875.5020103@trash.net> <20041230133401.GW32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230133401.GW32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <41D37875.5020103@trash.net> 2004-12-30 04:39
> 
>>-			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
>>-			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
>>-				printk("Action %s bad\n", (char*)RTA_DATA(kind));
>>+			if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
> 
> 
> The check should be RTA_PAYLOAD(kind) > IFNAMSIZ, == is ok
> if the terminating NUL is provided.

Thanks.

> 
> 
>> 				goto err_out;
>>-			}
>>+			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
>> 		} else {
> 
> 
> This will cause horrible crashes if no NUL is provided to terminate
> the name.
> 
> So I think this should be:
> 
> if (RTA_PAYLOAD(kind) > IFNAMSIZ)
> 	goto err_out;
> memset(act_name, ...);
> memcpy(act_name, RTA_DATA(kind), RTA_PAYLOAD(kind));
> act_name[IFNAMSIZ - 1] = '\0';
> 
> The memset is required to ensure 0 termination if kind is not and
> shorter than IFNAMSIZ. memcpy instead of str* to avoid using
> any form of str(n)len on a possibly not terminated string
> and setting IFNAMSIZ - 1 to NUL to ensure proper handling of
> a IFNAMSIZ long not terminated string.
> 
> I know it's unlikely but this might just save us some troubles later.

Agreed. I saved this change for later because there are more places
in net/sched that need to be fixed. I guess I'll just add a
rtattr_strncpy function.

Regards
Patrick
