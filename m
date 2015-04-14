From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 15:57:43 +0200
Message-ID: <552D1CD7.7040705@redhat.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com> <1429017572.7346.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429017572.7346.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2015 03:19 PM, Eric Dumazet wrote:
> On Tue, 2015-04-14 at 14:25 +0200, Denys Vlasenko wrote:
>> On x86 allyesconfig build:
>> The function compiles to 130 bytes of machine code.
>> It has 493 callsites.
>> Total reduction of vmlinux size: 27906 bytes.
>>
>>    text	     data      bss       dec     hex filename
>> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
>> 82419165 22255384 20627456 125302005 777f4f5 vmlinux5
> 
> This sounds a big hammer to me.
> 
> These savings probably comes from the BUG_ON() that could simply be
> removed.
> The second one for sure has no purpose. First one looks defensive.
> 
> For a typical (non allyesconfig) kernel, net_generic() would translate
> to :
> 
> return net->gen[id - 1]

My allyesconfig, with BUG_ON's commented out:

void *net_generic(const struct net *net, int id)
{
        struct net_generic *ng;
        void *ptr;

        rcu_read_lock();
        ng = rcu_dereference(net->gen);
//      BUG_ON(id == 0 || id > ng->len);
        ptr = ng->ptr[id - 1];
        rcu_read_unlock();

//      BUG_ON(!ptr);
        return ptr;
}

results in the following assembly:

net_generic:
        call    __fentry__
        pushq   %rbp    #
        movq    %rsp, %rbp      #,
        pushq   %r12    #
        movl    %esi, %r12d     # id, id
        pushq   %rbx    #
        movq    %rdi, %rbx      # net, net
        call    rcu_read_lock   #
        movq    4784(%rbx), %rbx        # MEM[(struct net_generic * const volatile *)net_2(D) + 4784B], _________p1
        call    debug_lockdep_rcu_enabled       #
        testl   %eax, %eax      # D.48937
        je      .L93    #,
        cmpb    $0, __warned.47396(%rip)        #, __warned
        jne     .L93    #,
        call    rcu_read_lock_held      #
        testl   %eax, %eax      # D.48944
        jne     .L93    #,
        movq    $.LC6, %rdx     #,
        movl    $51, %esi       #,
        movq    $.LC0, %rdi     #,
        movb    $1, __warned.47396(%rip)        #, __warned
        call    lockdep_rcu_suspicious  #
.L93:
        decl    %r12d   # tmp68
        movslq  %r12d, %r12     # tmp68, tmp69
        movq    24(%rbx,%r12,8), %rbx   # _________p1_4->ptr, ptr
        call    rcu_read_unlock #
        movq    %rbx, %rax      # ptr,
        popq    %rbx    #
        popq    %r12    #
        popq    %rbp    #
        ret

This is still 112 bytes of code.
