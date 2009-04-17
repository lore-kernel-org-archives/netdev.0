From: David Miller <davem@davemloft.net>
Subject: Re: Trouble using netlink_broadcast, need help
Date: Fri, 17 Apr 2009 02:20:12 -0700 (PDT)
Message-ID: <20090417.022012.18905025.davem@davemloft.net>
References: <8d9c773c0904170218h3faa88e3v909a30a49fb5c204@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: chocapiiic.tiery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752993AbZDQJUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:20:20 -0400
In-Reply-To: <8d9c773c0904170218h3faa88e3v909a30a49fb5c204@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry <chocapiiic.tiery@gmail.com>
Date: Fri, 17 Apr 2009 11:18:17 +0200

You'll get better help on netdev@vger.kernel.org which is where
the networking developers are subscribed, CC:'d

> I want to use netlink socket between kernel and userspace in order to
> get some information from kernel code.
> I use netlink_broadcast function in order to send information to a
> specific group.
> Everythings works when I use netlink_unicast.
> 
> Actually, I get theses errors when using broadcast:
> For kernel code: netlink broadcast return -3, No such process.
> User code: can't bind: errot -3.
> 
> I have put one programs at the end of my mail, who works when using
> unicast instead of
> broadcast, while GROUP_IB is set to 0, and I fix manually pid of the
> user-level program.
> When I changed unicast to broadcast, and I set GROUP_IB to an other
> value (I have tried many values, 1 24 65), I get the errors.
> 
> I have looked into kernel sources, and there is also somethings
> strange for me: in source code of netlink_kernel_create:
> if (group <32)
>   group = 32;
> This lines were not present in kernel 2.6.9.
> I am also wondering if there isn't somethings wrong with listenners:
> there are some tests on *has listenners*.
> 
> I use centos5.2, kernel 2.6.18-92.1.22
> 
> If someone can help me...
> 
> I have already asked help on other mailing list (kernelnewbies) , but
> I couln't succed to make netlink_broadcast working.
> 
> Regards,
> 
> Thierry
> 
> 
> ----
> kernel code:
> 
> #include <linux/autoconf.h>
> #include <linux/socket.h>
> #include <linux/kernel.h>
> #include <linux/module.h>
> #include <linux/netlink.h>
> #include <net/sock.h>
> #include <net/netlink.h>
> 
> #define MAX_PAYLOAD 1024
> #define NETLINK_IB 24
> #define GROUP_IB 1
> 
> 
> static struct sock *nl_sk = NULL;
> 
> static void nl_ib_data_ready (struct sock *sk, int len)
> {
>        wake_up_interruptible(sk->sk_sleep);
> }
> 
> static void netlink_ib_open()
> {
>        struct sk_buff *skb = NULL;
>        struct nlmsghdr *nlh = NULL;
>        int err;
> 
>        nl_sk = netlink_kernel_create(NETLINK_IB, GROUP_IB, nl_ib_data_ready,
> THIS_MODULE);
>        if (nl_sk == NULL) {
>                printk(KERN_ALERT "Error during netlink_kernel_create");
>        }
> 
>        skb = alloc_skb(NLMSG_SPACE(MAX_PAYLOAD),GFP_KERNEL);
>        nlh = (struct nlmsghdr *)skb->data;
>        nlh = skb_put(skb, NLMSG_ALIGN(1024));
>        nlh->nlmsg_pid = 0; // Send from kernel
>        nlh->nlmsg_flags = 0;
> 
>        strcpy(NLMSG_DATA(nlh), "Greeting from kernel!");
>        NETLINK_CB(skb).pid = 0;
>        NETLINK_CB(skb).dst_pid = 0; //Multicast
>        NETLINK_CB(skb).dst_group = GROUP_IB;// 0 if unicast
> 
>        printk( KERN_ALERT "Sending data...\n");
>        //err = netlink_unicast(nl_sk, skb, 6992, GFP_KERNEL);
>        err = netlink_broadcast(nl_sk, skb, 0, GROUP_IB, GFP_KERNEL);
>        if (err<0) {
>                printk(KERN_ALERT "Error during netlink_broadcast: %i\n",err);
>                if (err == -3) {
>                        printk(KERN_ALERT "No such process\n");
>                }
>        }
>        goto out;
> 
> nlmsg_failure:
>        printk(KERN_ALERT "Erreuuuur nlmsg_failure\n");
> 
> out:
>        sock_release(nl_sk->sk_socket);
> }
> 
> static int __init netlink_ib_module_init(void)
> {
>        printk(KERN_INFO "Init netlink_ib module\n");
>        netlink_ib_open();
>        return 0;
> }
> 
> static void __exit netlink_ib_module_exit(void)
> {
>        printk(KERN_INFO "Unloading netlink_ib module\n");
> }
> 
> MODULE_LICENSE("GPL");
> MODULE_DESCRIPTION("Kernel/User socket for IB support");
> module_init(netlink_ib_module_init);
> module_exit(netlink_ib_module_exit);
> 
> 
> ---------
> usercode
> 
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <stdio.h>
> #include <linux/netlink.h>
> #define NETLINK_IB 24
> #define GROUP_IB 1
> #define MAX_PAYLOAD 1024
> struct sockaddr_nl src_addr, dst_addr;
> struct nlmsghdr *nlh = NULL;
> struct msghdr msg;
> struct iovec iov;
> int sock_fd;
> 
> 
> int main(int argc, char ** argv)
> {
>        int err;
>        sock_fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_IB);
>        if (sock_fd<0) {
>                char s[BUFSIZ];
>                sprintf( s, "%s: can't assign fd for socket", argv[0] );
>                perror(s);
>                return -1;
>        }
> 
>        //memset(&src_addr, 0, sizeof(src_addr));
>        src_addr.nl_family = AF_NETLINK;
>        src_addr.nl_pad = 0;
>        src_addr.nl_pid = getpid();
>        src_addr.nl_groups = GROUP_IB; // Multicast
> 
>        err = bind(sock_fd, (struct sockaddr*)&src_addr, sizeof(src_addr));
>        if (err<0) {
>                char s[BUFSIZ];
>                sprintf( s, "%s: can't bind socket (%d)", argv[0], sock_fd );
>                perror(s);
>                return -1;
>        }
> 
>        memset(&dst_addr, 0, sizeof(dst_addr));
>        nlh = (struct nlhmsghdr *) malloc(NLMSG_SPACE(MAX_PAYLOAD));
>        memset(nlh, 0, NLMSG_SPACE(MAX_PAYLOAD));
> 
>        iov.iov_base = (void *)nlh;
>        iov.iov_len = NLMSG_SPACE(MAX_PAYLOAD);
>        msg.msg_name = (void *)&dst_addr;
>        msg.msg_namelen = sizeof(dst_addr);
>        msg.msg_iov = &iov;
>        msg.msg_iovlen = 1;
> 
>        printf("Waiting for messages from kernel...\n");
>        recvmsg(sock_fd, &msg, 0);
>        printf("Message : %s\n", NLMSG_DATA(nlh));
>        close(sock_fd);
> 
>        return 0;
> }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
