From: Manuel Perez Ayala <mperaya@alcazaba.unex.es>
Subject: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 11:33:08 +0200
Message-ID: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Since linux kernel 2.6.8 the tg3 support was broken on my PPC machines (P=
ower
Mac G4 silver) with data corruption.

After a while finally I've found the code responsible of my problems:

On debian kernel 2.6.8 in the tg3.c file, at line 7356 (inside the tg3_te=
st_dma
function) there are a conditional piece of code that compiles only if the
platform is NOT 386:

#ifndef CONFIG_X86
        {
                u8 byte;
                int cacheline_size;
                pci_read_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE, &byte=
);

                if (byte =3D=3D 0)
                        cacheline_size =3D 1024;
                else
                        cacheline_size =3D (int) byte * 4;

                switch (cacheline_size) {
                case 16:
                case 32:
                case 64:
                case 128:
                        if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
                            !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
                                tp->dma_rwctrl |=3D
                                        DMA_RWCTRL_WRITE_BNDRY_384_PCIX;
                                break;
                        } else if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)=
 {
                                tp->dma_rwctrl &=3D
                                        ~(DMA_RWCTRL_PCI_WRITE_CMD);
                                tp->dma_rwctrl |=3D
                                        DMA_RWCTRL_WRITE_BNDRY_128_PCIE;
                                break;
                        }
                        /* fallthrough */
                case 256:
                        if (!(tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
                            !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
                                tp->dma_rwctrl |=3D
                                        DMA_RWCTRL_WRITE_BNDRY_256;
                        else if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)=
)
                                tp->dma_rwctrl |=3D
                                        DMA_RWCTRL_WRITE_BNDRY_256_PCIX;
                };
        }
#endif


This has changed from version 2.6.7 (also Debian dist). At line 6964 (ins=
ide the
same function) was:

#ifndef CONFIG_X86
        {
                u8 byte;
                int cacheline_size;
                pci_read_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE, &byte=
);

                if (byte =3D=3D 0)
                        cacheline_size =3D 1024;
                else
                        cacheline_size =3D (int) byte * 4;

                tp->dma_rwctrl &=3D ~(DMA_RWCTRL_READ_BNDRY_MASK |
                                    DMA_RWCTRL_WRITE_BNDRY_MASK);

                switch (cacheline_size) {
                case 16:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_16 |
                                 DMA_RWCTRL_WRITE_BNDRY_16);
                        break;

                case 32:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_32 |
                                 DMA_RWCTRL_WRITE_BNDRY_32);
                        break;

                case 64:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_64 |
                                 DMA_RWCTRL_WRITE_BNDRY_64);
                        break;

                case 128:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_128 |
                                 DMA_RWCTRL_WRITE_BNDRY_128);
                        break;

                case 256:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_256 |
                                 DMA_RWCTRL_WRITE_BNDRY_256);
                        break;

                case 512:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_512 |
                                 DMA_RWCTRL_WRITE_BNDRY_512);
                        break;

                case 1024:
                        tp->dma_rwctrl |=3D
                                (DMA_RWCTRL_READ_BNDRY_1024 |
                                 DMA_RWCTRL_WRITE_BNDRY_1024);
                        break;
                };
        }
#endif


If I replace the 2.6.8 piece of code with the 2.6.7 one and compile the c=
ode, it
seems to work without problems of data corruption.

Perhaps is there a better solution adding or modifiyng only certain 2.6.8=
 code
to make the thinks works, but this works for me.

If anybody can sugest anything about it I will be very happy to try and r=
eport
anything about it.

Thanks.


----------
Manuel Perez Ayala
mperaya@alcazaba.unex.es
Facultad de Biblioteconom=EDa y Documentaci=F3n
Universidad de Extremadura
