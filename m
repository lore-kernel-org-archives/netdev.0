From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Fri, 20 Apr 2007 12:46:58 +0800
Message-ID: <6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com>
References: <200704091146.32346.rgetz@blackfin.uclinux.org>
	 <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com>
	 <200704101952.05380.rgetz@blackfin.uclinux.org>
	 <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
	 <2817.1176910411@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "David Howells" <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:35043 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412AbXDTEq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 00:46:59 -0400
Received: by nz-out-0506.google.com with SMTP id s1so654994nze
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2007 21:46:59 -0700 (PDT)
In-Reply-To: <2817.1176910411@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/07, David Howells <dhowells@redhat.com> wrote:
> Aubrey Li <aubreylee@gmail.com> wrote:
>
> > Here, in the attachment I wrote a small test app. Please correct if
> > there is anything wrong, and feel free to improve it.
>
> Okay... I have that working... probably.  I don't know what output it's
> supposed to produce, but I see this:
>
>         # /packet-mmap/sample_packet_mmap
>         00-00-00-01-00-00-00-8a-00-00-00-8a-00-42-00-50-
>         38-43-13-a0-00-07-ff-3c-00-00-00-00-00-00-00-00-
>         00-11-08-00-00-00-00-01-00-01-00-06-00-d0-b7-de-
>         32-7b-00-00-00-00-00-00-00-00-00-00-00-00-00-00-
>         00-00-00-90-cc-a2-75-6b-00-d0-b7-de-32-7b-08-00-
>         45-00-00-7c-00-00-40-00-40-11-b4-13-c0-a8-02-80-
>         c0-a8-02-8d-08-01-03-20-00-68-8e-65-7f-5b-7e-03-
>         00-00-00-01-00-00-00-00-00-00-00-00-00-00-00-00-
>         00-00-00-00-00-00-00-00-00-00-00-01-00-00-81-a4-
>         00-00-00-01-00-00-00-00-00-00-00-00-00-1d-b8-86-
>         00-00-10-00-ff-ff-ff-ff-00-00-0e-f0-00-00-09-02-
>         01-cb-03-16-46-26-38-0d-00-00-00-00-46-26-38-1e-
>         00-00-00-00-46-26-38-1e-00-00-00-00-00-00-00-00-
>         00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00- [repeated]
>
> Does that look reasonable?
>
> I've attached the preliminary patch.  Note four things about it:
>
>  (1) I've had to add the get_unmapped_area() op to the proto_ops struct, but
>      I've only done it for CONFIG_MMU=n as making it available for CONFIG_MMU=y
>      could cause problems.
>
>  (2) There's a race between packet_get_unmapped_area() being called and
>      packet_mmap() being called.
>
>  (3) I've added an extra check into packet_set_ring() to make sure the caller
>      isn't asking for a combination of buffer size and count that will exceed
>      ULONG_MAX.  This protects a multiply done elsewhere.
>
>  (4) The entire data buffer is allocated as one contiguous lump in NOMMU-mode.
>
> David
>
> ---
> [PATCH] NOMMU: Support mmap() on AF_PACKET sockets
>
> From: David Howells <dhowells@redhat.com>
>
> Support mmap() on AF_PACKET sockets in NOMMU-mode kernels.
>
> Signed-Off-By: David Howells <dhowells@redhat.com>
> ---
>
>  include/linux/net.h    |    7 +++
>  include/net/sock.h     |    8 +++
>  net/core/sock.c        |   10 ++++
>  net/packet/af_packet.c |  118 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/socket.c           |   77 +++++++++++++++++++++++++++++++
>  5 files changed, 219 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 4db21e6..9e77cf6 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -161,6 +161,11 @@ struct proto_ops {
>         int             (*recvmsg)   (struct kiocb *iocb, struct socket *sock,
>                                       struct msghdr *m, size_t total_len,
>                                       int flags);
> +#ifndef CONFIG_MMU
> +       unsigned long   (*get_unmapped_area)(struct file *file, struct socket *sock,
> +                                            unsigned long addr, unsigned long len,
> +                                            unsigned long pgoff, unsigned long flags);
> +#endif
>         int             (*mmap)      (struct file *file, struct socket *sock,
>                                       struct vm_area_struct * vma);
>         ssize_t         (*sendpage)  (struct socket *sock, struct page *page,
> @@ -191,6 +196,8 @@ extern int               sock_sendmsg(struct socket *sock, struct msghdr *msg,
>  extern int          sock_recvmsg(struct socket *sock, struct msghdr *msg,
>                                   size_t size, int flags);
>  extern int          sock_map_fd(struct socket *sock);
> +extern void         sock_make_mappable(struct socket *sock,
> +                                       unsigned long prot);
>  extern struct socket *sockfd_lookup(int fd, int *err);
>  #define                     sockfd_put(sock) fput(sock->file)
>  extern int          net_ratelimit(void);
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 2c7d60c..d91edea 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -841,6 +841,14 @@ extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
>                                                 struct msghdr *, size_t);
>  extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
>                                                 struct msghdr *, size_t, int);
> +#ifndef CONFIG_MMU
> +extern unsigned long           sock_no_get_unmapped_area(struct file *,
> +                                                         struct socket *,
> +                                                         unsigned long,
> +                                                         unsigned long,
> +                                                         unsigned long,
> +                                                         unsigned long);
> +#endif
>  extern int                     sock_no_mmap(struct file *file,
>                                              struct socket *sock,
>                                              struct vm_area_struct *vma);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 27c4f62..b288799 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1364,6 +1364,15 @@ int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
>         return -EOPNOTSUPP;
>  }
>
> +#ifndef CONFIG_MMU
> +unsigned long sock_no_get_unmapped_area(struct file *file, struct socket *sock,
> +                                       unsigned long addr, unsigned long len,
> +                                       unsigned long pgoff, unsigned long flags)
> +{
> +       return (unsigned long) -ENODEV;
> +}
> +#endif
> +
>  int sock_no_mmap(struct file *file, struct socket *sock, struct vm_area_struct *vma)
>  {
>         /* Mirror missing mmap method error code */
> @@ -1943,6 +1952,7 @@ EXPORT_SYMBOL(sock_no_getname);
>  EXPORT_SYMBOL(sock_no_getsockopt);
>  EXPORT_SYMBOL(sock_no_ioctl);
>  EXPORT_SYMBOL(sock_no_listen);
> +EXPORT_SYMBOL(sock_no_get_unmapped_area);
>  EXPORT_SYMBOL(sock_no_mmap);
>  EXPORT_SYMBOL(sock_no_poll);
>  EXPORT_SYMBOL(sock_no_recvmsg);
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 28d47e8..12d970a 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -78,6 +78,7 @@
>  #include <linux/poll.h>
>  #include <linux/module.h>
>  #include <linux/init.h>
> +#include <asm/mman.h>
>
>  #ifdef CONFIG_INET
>  #include <net/inet_common.h>
> @@ -1023,6 +1024,7 @@ static int packet_create(struct socket *sock, int protocol)
>                 sock->ops = &packet_ops_spkt;
>  #endif
>         sock_init_data(sock, sk);
> +       sock_make_mappable(sock, PROT_READ | PROT_WRITE);
>
>         po = pkt_sk(sk);
>         sk->sk_family = PF_PACKET;
> @@ -1629,6 +1631,7 @@ static inline struct page *pg_vec_endpage(char *one_pg_vec, unsigned int order)
>         return virt_to_page(one_pg_vec + (PAGE_SIZE << order) - 1);
>  }
>
> +#ifdef CONFIG_MMU
>  static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
>  {
>         int i;
> @@ -1671,6 +1674,45 @@ out_free_pgvec:
>         goto out;
>  }
>
> +#else
> +/*
> + * free the buffer pointer block and all the buffers for NOMMU
> + */
> +static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
> +{
> +       kfree(pg_vec[0]);
> +       kfree(pg_vec);
> +}
> +
> +/*
> + * allocate the buffer pointer block and all the buffer blocks for the mappable
> + * AF_PACKET buffers for NOMMU mode
> + * - in NOMMU mode the buffers must be contiguous with each other
> + */
> +static char **alloc_pg_vec(struct tpacket_req *req, int order)
> +{
> +       char *buffers;
> +       char **ptrblock;
> +       int loop;
> +
> +       buffers = kcalloc(req->tp_block_size, req->tp_block_nr, GFP_KERNEL);
> +       if (!buffers)
> +               return ERR_PTR(-ENOMEM);
> +       ptrblock = kmalloc(sizeof(char *) * req->tp_block_nr, GFP_KERNEL);
> +       if (!ptrblock) {
> +               kfree(buffers);
> +               return ERR_PTR(-ENOMEM);
> +       }
> +
> +       for (loop = 0; loop < req->tp_block_nr; loop++) {
> +               ptrblock[loop] = buffers;
> +               buffers += req->tp_block_size;
> +       }
> +
> +       return ptrblock;
> +}
> +#endif
> +
>  static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing)
>  {
>         char **pg_vec = NULL;
> @@ -1695,6 +1737,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
>                         return -EINVAL;
>                 if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
>                         return -EINVAL;
> +               if (unlikely(ULONG_MAX / req->tp_block_size < req->tp_block_nr))
> +                       return -ENOMEM;
>
>                 po->frames_per_block = req->tp_block_size/req->tp_frame_size;
>                 if (unlikely(po->frames_per_block <= 0))
> @@ -1783,6 +1827,7 @@ out:
>         return err;
>  }
>
> +#ifdef CONFIG_MMU
>  static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_struct *vma)
>  {
>         struct sock *sk = sock->sk;
> @@ -1823,7 +1868,72 @@ out:
>         release_sock(sk);
>         return err;
>  }
> -#endif
> +
> +#else
> +/*
> + * find out where the socket buffers are so that NOMMU mmap can return the
> + * address directly
> + */
> +static unsigned long packet_get_unmapped_area(struct file *file,
> +                                             struct socket *sock,
> +                                             unsigned long addr,
> +                                             unsigned long len,
> +                                             unsigned long pgoff,
> +                                             unsigned long flags)
> +{
> +       struct sock *sk = sock->sk;
> +       struct packet_sock *po = pkt_sk(sk);
> +
> +       /* check that they want to map the whole buffer */
> +       if (pgoff)
> +               return (unsigned long) -EINVAL;
> +
> +       lock_sock(sk);
> +       if (!po->pg_vec ||
> +           len != po->pg_vec_len * po->pg_vec_pages * PAGE_SIZE)
> +               addr = (unsigned long) -EINVAL;
> +       else
> +               addr = (unsigned long) po->pg_vec[0];
> +       release_sock(sk);
> +       return addr;
> +}
> +
> +/*
> + * set the mapping of a packet socket buffer for NOMMU mmap
> + */
> +static int packet_mmap(struct file *file, struct socket *sock,
> +                      struct vm_area_struct *vma)
> +{
> +       struct sock *sk = sock->sk;
> +       struct packet_sock *po = pkt_sk(sk);
> +       unsigned long len;
> +       int ret;
> +
> +       if (vma->vm_pgoff)
> +               return -EINVAL;
> +
> +       lock_sock(sk);
> +
> +       /* check that they want to map the whole buffer */
> +       len = vma->vm_end - vma->vm_start;
> +       if (!po->pg_vec ||
> +           len != po->pg_vec_len * po->pg_vec_pages * PAGE_SIZE) {
> +               ret = -EINVAL;
> +       } else if (vma->vm_start != (unsigned long) po->pg_vec[0]) {
> +               /* someone found the gap between get_unmapped_area and mmap */
> +               ret = -ESTALE;
> +       } else {
> +               atomic_inc(&po->mapped);
> +               vma->vm_ops = &packet_mmap_ops;
> +               ret = 0;
> +       }
> +
> +       release_sock(sk);
> +       return ret;
> +}
> +
> +#endif /* CONFIG_MMU */
> +#endif /* CONFIG_PACKET_MMAP */
>
>
>  #ifdef CONFIG_SOCK_PACKET
> @@ -1844,6 +1954,9 @@ static const struct proto_ops packet_ops_spkt = {
>         .getsockopt =   sock_no_getsockopt,
>         .sendmsg =      packet_sendmsg_spkt,
>         .recvmsg =      packet_recvmsg,
> +#ifndef CONFIG_MMU
> +       .get_unmapped_area = sock_no_get_unmapped_area,
> +#endif
>         .mmap =         sock_no_mmap,
>         .sendpage =     sock_no_sendpage,
>  };
> @@ -1866,6 +1979,9 @@ static const struct proto_ops packet_ops = {
>         .getsockopt =   packet_getsockopt,
>         .sendmsg =      packet_sendmsg,
>         .recvmsg =      packet_recvmsg,
> +#ifndef CONFIG_MMU
> +       .get_unmapped_area = packet_get_unmapped_area,
> +#endif
>         .mmap =         packet_mmap,
>         .sendpage =     sock_no_sendpage,
>  };
> diff --git a/net/socket.c b/net/socket.c
> index ea8f81a..4109db6 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -87,6 +87,7 @@
>
>  #include <asm/uaccess.h>
>  #include <asm/unistd.h>
> +#include <asm/mman.h>
>
>  #include <net/compat.h>
>
> @@ -98,6 +99,13 @@ static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
>                          unsigned long nr_segs, loff_t pos);
>  static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
>                           unsigned long nr_segs, loff_t pos);
> +#ifndef CONFIG_MMU
> +static unsigned long sock_get_unmapped_area(struct file *file,
> +                                           unsigned long addr,
> +                                           unsigned long len,
> +                                           unsigned long pgoff,
> +                                           unsigned long flags);
> +#endif
>  static int sock_mmap(struct file *file, struct vm_area_struct *vma);
>
>  static int sock_close(struct inode *inode, struct file *file);
> @@ -127,6 +135,9 @@ static const struct file_operations socket_file_ops = {
>  #ifdef CONFIG_COMPAT
>         .compat_ioctl = compat_sock_ioctl,
>  #endif
> +#ifndef CONFIG_MMU
> +       .get_unmapped_area = sock_get_unmapped_area,
> +#endif
>         .mmap =         sock_mmap,
>         .open =         sock_no_open,   /* special open code to disallow open via /proc */
>         .release =      sock_close,
> @@ -136,6 +147,26 @@ static const struct file_operations socket_file_ops = {
>  };
>
>  /*
> + * capabilities for non-mappable sockets
> + * - does not permit mmap at all
> + * - no readahead or I/O queue unplugging required
> + */
> +struct backing_dev_info non_mappable_socket_bdi = {
> +       .capabilities   = 0,
> +};
> +
> +/*
> + * capabilities for read/write mappable sockets
> + * - permits shared-mmap for read and write only
> + * - does not permit private mmap
> + * - no readahead or I/O queue unplugging required
> + */
> +struct backing_dev_info rw_mappable_socket_bdi = {
> +       .capabilities   = (BDI_CAP_MAP_DIRECT | BDI_CAP_READ_MAP |
> +                          BDI_CAP_WRITE_MAP),
> +};
> +
> +/*
>   *     The protocol list. Each protocol is registered in here.
>   */
>
> @@ -415,6 +446,34 @@ static struct socket *sock_from_file(struct file *file, int *err)
>  }
>
>  /**
> + *     sock_make_mappable -    Change the mmappability of a socket
> + *     @sock: The socket to alter
> + *     @prot: The mmap protection to permit
> + *
> + *     The nominated socket has its backing device information selection
> + *     changed to indicate to mmap() what sort of mappings are available on
> + *     this socket.
> + */
> +void sock_make_mappable(struct socket *sock, unsigned long prot)
> +{
> +       struct address_space *mapping = &SOCK_INODE(sock)->i_data;
> +
> +       switch (prot) {
> +       case 0:
> +               mapping->backing_dev_info = &non_mappable_socket_bdi;
> +               break;
> +       case PROT_READ | PROT_WRITE:
> +               mapping->backing_dev_info = &rw_mappable_socket_bdi;
> +               break;
> +       case PROT_READ:
> +       case PROT_WRITE:
> +       default:
> +               BUG();
> +               break;
> +       }
> +}
> +
> +/**
>   *     sockfd_lookup   -       Go from a file number to its socket slot
>   *     @fd: file handle
>   *     @err: pointer to an error code return
> @@ -482,6 +541,7 @@ static struct socket *sock_alloc(void)
>         inode->i_mode = S_IFSOCK | S_IRWXUGO;
>         inode->i_uid = current->fsuid;
>         inode->i_gid = current->fsgid;
> +       inode->i_data.backing_dev_info = &non_mappable_socket_bdi;
>
>         get_cpu_var(sockets_in_use)++;
>         put_cpu_var(sockets_in_use);
> @@ -918,6 +978,22 @@ static unsigned int sock_poll(struct file *file, poll_table *wait)
>         return sock->ops->poll(file, sock, wait);
>  }
>
> +#ifndef CONFIG_MMU
> +static unsigned long sock_get_unmapped_area(struct file *file,
> +                                           unsigned long addr,
> +                                           unsigned long len,
> +                                           unsigned long pgoff,
> +                                           unsigned long flags)
> +{
> +       struct socket *sock = file->private_data;
> +
> +       if (!sock->ops->get_unmapped_area)
> +               return -ENOSYS;
> +       return sock->ops->get_unmapped_area(file, sock,
> +                                           addr, len, pgoff, flags);
> +}
> +#endif
> +
>  static int sock_mmap(struct file *file, struct vm_area_struct *vma)
>  {
>         struct socket *sock = file->private_data;
> @@ -2288,6 +2364,7 @@ EXPORT_SYMBOL(sock_create);
>  EXPORT_SYMBOL(sock_create_kern);
>  EXPORT_SYMBOL(sock_create_lite);
>  EXPORT_SYMBOL(sock_map_fd);
> +EXPORT_SYMBOL(sock_make_mappable);
>  EXPORT_SYMBOL(sock_recvmsg);
>  EXPORT_SYMBOL(sock_register);
>  EXPORT_SYMBOL(sock_release);
>

The patch works properly on my side. But
1) I'm not sure why you re-wrote alloc/free_pg_vec function, doesn't
the current implement work for NOMMU? I know you want to allocate the
entire data buffer as one contiguous lump, but is it really necessary?

2) So the mapped pages doesn't count into NR_FILE_MAPPED, is it a problem?

-Aubrey
