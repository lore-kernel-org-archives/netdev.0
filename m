From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: hfsc and huge set of rules
Date: Sun, 01 Aug 2004 19:53:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410D2E30.2050104@trash.net>
References: <20040729211844.61e8d328.davem@redhat.com> <410A2449.3020701@trash.net> <20040730110815.GA7812@krezus.e-wro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, devik@cdi.cz,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
In-Reply-To: <20040730110815.GA7812@krezus.e-wro.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tomasz Paszkowski wrote:

>On Fri, Jul 30, 2004 at 12:34:49PM +0200, Patrick McHardy wrote:
>  
>
>>hfsc_destroy_qdisc takes O(n) time wrt. the number of classes,
>>but 5-6 seconds is still long. If all these classes contain inner
>>qdiscs other than the default, I guess removing the classes from
>>dev->qdisc_list in qdisc_destroy takes up most of the time, with
>>n O(n) operations. The __qdisc_destroy rcu callback also calls
>>reset before destroy, I don't know any qdisc where this is really
>>neccessary. Without inner qdiscs, I need to see the script first to
>>judge what's going wrong. Tomasz ?
>>    
>>
>
>http://www.e-wro.pl/~acid/tc.batch.gz. In my opinion it's not the case
>of expensive algorithms, but the number of classes. With this rule set loaded
>(tc -b tc.batch) command:
>
>for i in 'e1.903 e0.930 e0.931 e0.932' ; do
>	tc qdisc del dev ${i} root
>done
>completly freezes machine for about 5-6 seconds.
>  
>
I've done some profiles with your script (on an old kernel without
the lockless loopback patch), qdisc_destroy takes up 89% of the time
when destroying the qdiscs.

These are the exact results:

- execute the script on unpatched kernel:

time:
real    2m28.822s
user    0m2.347s
sys     2m25.395s

top 5 in profile:
799773   65.4986  vmlinux                  vmlinux                  
qdisc_lookup
199964   16.3763  vmlinux                  vmlinux                  
qdisc_destroy
92504     7.5758  sch_hfsc.ko              sch_hfsc                 
hfsc_adjust_levels
36722     3.0074  sch_hfsc.ko              sch_hfsc                 
hfsc_get_class
12471     1.0213  vmlinux                  vmlinux                  
mark_offset_tsc


- execute the script on kernel using double-linked lists for 
dev->qdisc_list:

time:
real    0m51.804s
user    0m2.286s
sys     0m48.795s

top 5 in profile:
201152   49.6049  vmlinux                  vmlinux                  
qdisc_lookup
92706    22.8617  sch_hfsc.ko              sch_hfsc                 
hfsc_adjust_levels
37140     9.1589  sch_hfsc.ko              sch_hfsc                 
hfsc_get_class
12310     3.0357  sch_hfsc.ko              sch_hfsc                 
hfsc_bind_tcf
12190     3.0061  sch_hfsc.ko              sch_hfsc                 
hfsc_change_class

- destroy the qdiscs on unpatched kernel:

time:
real    0m13.258s
user    0m0.019s
sys     0m13.206s

top 5 in profile:
29839    89.5367  vmlinux                  vmlinux                  
qdisc_destroy
1229      3.6878  sch_hfsc.ko              sch_hfsc                 
hfsc_reset_class
338       1.0142  vmlinux                  vmlinux                  
mark_offset_tsc
289       0.8672  vmlinux                  vmlinux                  
qdisc_reset
287       0.8612  sch_hfsc.ko              sch_hfsc                 
rtsc_init

- destroy the qdiscs on kernel using double-linked lists for 
dev->qdisc_list:

time:
real    0m0.389s
user    0m0.019s
sys     0m0.363s

top 5 in profile:
1261     33.6896  sch_hfsc.ko              sch_hfsc                 
hfsc_reset_class
311       8.3088  sch_hfsc.ko              sch_hfsc                 
rtsc_init
277       7.4005  vmlinux                  vmlinux                  
qdisc_reset
187       4.9960  vmlinux                  vmlinux                  
free_block
181       4.8357  vmlinux                  vmlinux                  kfree

So double-linked lists clearly solve your problem. Using a hash would 
speed up
creating the qdiscs even more, but it wastes too much memory in my opinion.
I'm going to send a patch after I've fixed the other problems with 
qdisc_destroy.

>I was trying do modify the code od hfsc_qdisc_destroy scheduling another
>task using schedule_task (), but i don't have enough knowledge to do deal
>with proper locking of qdisc structures.
>  
>
That doesn't work, hfsc_qdisc_destroy is called under a lock.

Regards
Patrick
