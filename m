From: "Qi, Yanling" <Yanling.Qi@lsi.com>
Subject: SG_IO with >4k buffer size to iscsi sg device causes "Bad page" panic
Date: Tue, 8 May 2007 12:08:51 -0600
Message-ID: <0F08E10B769EAF4EA2C43A573B8CC87FB106C0@NAMAIL3.ad.lsil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Qi, Yanling" <Yanling.Qi@lsi.com>,
	"Mike Christie" <michaelc@cs.wisc.edu>, <dougg@torque.net>,
	"James Bottomley" <James.Bottomley@SteelEye.com>
To: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<open-iscsi@googlegroups.com>,
	<linux-iscsi-devel@lists.sourceforge.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

This panic is related to the interactions between scsi/sg.c, iscsi
initiator and tcp on the RHEL 2.6.9-42 kernel. But we may also have the
similar problem with open-iscsi initiator. I will explain why we see the
Bad page panic first. I did a patch to the sg driver to workaround the
problem and seek for ideas where we should fix the problem.

When sg driver accepts a sg_io request from user space, it invokes
kernel API __get_free_pages() to allocate multiple pages for holding
user space data IO request. The allocated pages will consist of one base
page and a number of sub pages (total 8 pages for a big request). The
pages have the following attributes after they are allocated by the sg
driver. 
	0 page:000001007fb89ac0 flags:0x01000000
mapping:0000000000000000 mapcount:0 count:1
	1 page:000001007fb89af8 flags:0x01000004
mapping:0000000000000000 mapcount:0 count:0
	2 page:000001007fb89b30 flags:0x01000004
mapping:0000000000000000 mapcount:0 count:0

Please note that only the base page has count=1 and all subpages have
count=0. 

After the request reaches iscsi-sfnet initiator driver, the iscsi-sfnet
driver will send a buffer with multiple pages one by one through network
interface API.
 
 rc = sock->ops->sendpage(sock, pg, pg_offset, len, flags);

At the network layer (linux/net/ipv4/tcp.c), the sendpage() operation
will perform get_page() first and then put_page() later. The get_page()
will increase the page's count by 1. The put_page() will perform the
following (linux/mm/swap.c)

void put_page(struct page *page)
{
        if (unlikely(PageCompound(page))) {
                page = (struct page *)page->private;
                if (put_page_testzero(page)) {
                        void (*dtor)(struct page *page);
  
                        dtor = (void (*)(struct page *))page[1].mapping;
                        (*dtor)(page);
                }
                return;
        }
        if (!PageReserved(page) && put_page_testzero(page))
               __page_cache_release(page);
} 

Please note that if the count is 0, the page will be released and
recycled to the free-page pool. 

At the time when sg driver is ready to free its allocated pages by
invoking free_pages(), the sub-pages is already re-used by someone else.
We will get "Bad page kernel expeption" such as the following 

Bad page state at __free_pages_ok (in process 'java', page
000001007fb89b30)
flags:0x0100103c mapping:0000010075a4eaf0 mapcount:0 count:2
Backtrace:
Call Trace:<ffffffff8015d37f>{bad_page+112}
<ffffffff8015d713>{__free_pages_ok+154} 
      <ffffffffa01d9fa5>{:sg:sg_remove_scat+276} <ffffffffa01da13e>
{:sg:sg_finish_rem_req+238} 
      <ffffffffa01da56a>{:sg:sg_new_read+1050}
<ffffffffa01dcb48>{:sg:sg_ioctl+929} 
      <ffffffff8030a0f5>{thread_return+0}
<ffffffff801d42e6>{selinux_file_ioctl+711} 
      <ffffffff8030ab88>{schedule_timeout+224}
<ffffffff8016bfb6>{find_extend_vma+22} 
      <ffffffff8014c6b0>{unqueue_me+138}
<ffffffff8014c8ce>{do_futex+441} 
      <ffffffff80135752>{autoremove_wake_function+0}
<ffffffff80135752>{autoremove_wake_function+0} 
      <ffffffff8018ae05>{sys_ioctl+853}
<ffffffff8012a122>{sg_ioctl_trans+832} 
      <ffffffff8019e8ac>{compat_sys_ioctl+235}
<ffffffff80125bbb>{sysenter_do_call+27}
In the above oops, the page with page address 000001007fb89b30 has been
reused with active count 2 and memory mapped. Because the sg driver
tries to free a page that is mapped and active, we got the above bad
page panic.

I did the following patch to the sg.c. The sg driver will set
PG_reserved for all sub-pages at sg_page_malloc() time and clear the
bit/count at sg_page_free() time. I tested it and it worked great. Do
you see any side impacts with this patch? Is this a right place to fix
the panic? We may have similar problem for st driver.

--- linux-2.6.9/drivers/scsi/sg.c       2007-05-07 22:14:33.000000000
-0500
+++ /home/yqi/working_sg_iscsi_sfnet/sg.c       2007-05-07
22:45:26.000000000 -0500
@@ -2551,8 +2551,9 @@ sg_page_malloc(int rqSz, int lowDma, int
 {
        char *resp = NULL;
        int page_mask;
-       int order, a_size;
+       int order, a_size, m;
        int resSz = rqSz;
+       struct page *tmppage;

        if (rqSz <= 0)
                return resp;
@@ -2571,6 +2572,13 @@ sg_page_malloc(int rqSz, int lowDma, int
                resp = (char *) __get_free_pages(page_mask, order);
/* try half */
                resSz = a_size;
        }
+       tmppage = virt_to_page(resp);
+       for( m = PAGE_SIZE; m < resSz; m += PAGE_SIZE )
+       {
+               tmppage++;
+               SetPageReserved(tmppage);
+       }
+
        if (resp) {
                if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SYS_RAWIO))
                        memset(resp, 0, resSz);
@@ -2583,12 +2591,20 @@ sg_page_malloc(int rqSz, int lowDma, int
 static void
 sg_page_free(char *buff, int size)
 {
-       int order, a_size;
+       int order, a_size, m;
+       struct page * tmppage;
+       tmppage = virt_to_page(buff);

        if (!buff)
                return;
        for (order = 0, a_size = PAGE_SIZE; a_size < size;
             order++, a_size <<= 1) ;
+       for( m = PAGE_SIZE; m < size; m += PAGE_SIZE )
+       {
+               tmppage++;
+               set_page_count(tmppage,0);
+               ClearPageReserved(tmppage);
+       }
        free_pages((unsigned long) buff, order);
 }

Thanks,

Yanling

Yanling Qi
Engenio Storage Group - LSI Logic
512-794-3713 (Office)
512-794-3702 (Fax)
yanling.qi@lsi.com
 
