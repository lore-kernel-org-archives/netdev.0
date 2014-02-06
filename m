From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH v2 tip 6/7] LLVM BPF backend
Date: Wed,  5 Feb 2014 17:10:45 -0800
Message-ID: <1391649046-4383-7-git-send-email-ast@plumgrid.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

standalone BPF backend for LLVM 3.2, 3.3 and 3.4
See tools/bpf/llvm/README.txt

Written in LLVM codying style and LLVM license.

Most of the lib/Target/BPF/* is boilerplate code
which is required for any LLVM backend.

Backend enforces presence of 'license' section in the source C file.

Makefile* is simplified LLVM build system

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 tools/bpf/llvm/LICENSE.TXT                         |   70 ++
 tools/bpf/llvm/Makefile.rules                      |  641 +++++++++++++++++++
 tools/bpf/llvm/README.txt                          |   23 +
 tools/bpf/llvm/bld/.gitignore                      |    2 +
 tools/bpf/llvm/bld/Makefile                        |   27 +
 tools/bpf/llvm/bld/Makefile.common                 |   14 +
 tools/bpf/llvm/bld/Makefile.config                 |  124 ++++
 .../llvm/bld/include/llvm/Config/AsmParsers.def    |    8 +
 .../llvm/bld/include/llvm/Config/AsmPrinters.def   |    9 +
 .../llvm/bld/include/llvm/Config/Disassemblers.def |    8 +
 tools/bpf/llvm/bld/include/llvm/Config/Targets.def |    9 +
 .../bpf/llvm/bld/include/llvm/Support/DataTypes.h  |   96 +++
 tools/bpf/llvm/bld/lib/Makefile                    |   11 +
 .../llvm/bld/lib/Target/BPF/InstPrinter/Makefile   |   10 +
 .../llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile  |   11 +
 tools/bpf/llvm/bld/lib/Target/BPF/Makefile         |   17 +
 .../llvm/bld/lib/Target/BPF/TargetInfo/Makefile    |   10 +
 tools/bpf/llvm/bld/lib/Target/Makefile             |   11 +
 tools/bpf/llvm/bld/tools/Makefile                  |   12 +
 tools/bpf/llvm/bld/tools/llc/Makefile              |   15 +
 tools/bpf/llvm/lib/Target/BPF/BPF.h                |   30 +
 tools/bpf/llvm/lib/Target/BPF/BPF.td               |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp    |  100 +++
 tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp      |   62 ++
 tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td    |   24 +
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp |   36 ++
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h   |   35 +
 tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp  |  182 ++++++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp  |  676 ++++++++++++++++++++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h    |  105 +++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td   |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp     |  162 +++++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h       |   53 ++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td      |  455 +++++++++++++
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp   |   77 +++
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h     |   40 ++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp  |  122 ++++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h    |   65 ++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td   |   39 ++
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp     |   23 +
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h       |   33 +
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp |   72 +++
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h   |   69 ++
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp  |   79 +++
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.h    |   34 +
 .../lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp  |   85 +++
 .../llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h |   33 +
 .../Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp |  119 ++++
 .../lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h     |   34 +
 .../Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp   |  120 ++++
 .../lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h |   67 ++
 .../Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp    |  115 ++++
 .../lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h  |   56 ++
 .../lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp    |   13 +
 tools/bpf/llvm/tools/llc/llc.cpp                   |  381 +++++++++++
 55 files changed, 4782 insertions(+)
 create mode 100644 tools/bpf/llvm/LICENSE.TXT
 create mode 100644 tools/bpf/llvm/Makefile.rules
 create mode 100644 tools/bpf/llvm/README.txt
 create mode 100644 tools/bpf/llvm/bld/.gitignore
 create mode 100644 tools/bpf/llvm/bld/Makefile
 create mode 100644 tools/bpf/llvm/bld/Makefile.common
 create mode 100644 tools/bpf/llvm/bld/Makefile.config
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/AsmParsers.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/AsmPrinters.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/Disassemblers.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/Targets.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Support/DataTypes.h
 create mode 100644 tools/bpf/llvm/bld/lib/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/InstPrinter/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/TargetInfo/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/Makefile
 create mode 100644 tools/bpf/llvm/bld/tools/Makefile
 create mode 100644 tools/bpf/llvm/bld/tools/llc/Makefile
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPF.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPF.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp
 create mode 100644 tools/bpf/llvm/tools/llc/llc.cpp

diff --git a/tools/bpf/llvm/LICENSE.TXT b/tools/bpf/llvm/LICENSE.TXT
new file mode 100644
index 0000000..00cf601
--- /dev/null
+++ b/tools/bpf/llvm/LICENSE.TXT
@@ -0,0 +1,70 @@
+==============================================================================
+LLVM Release License
+==============================================================================
+University of Illinois/NCSA
+Open Source License
+
+Copyright (c) 2003-2012 University of Illinois at Urbana-Champaign.
+All rights reserved.
+
+Developed by:
+
+    LLVM Team
+
+    University of Illinois at Urbana-Champaign
+
+    http://llvm.org
+
+Permission is hereby granted, free of charge, to any person obtaining a copy of
+this software and associated documentation files (the "Software"), to deal with
+the Software without restriction, including without limitation the rights to
+use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+of the Software, and to permit persons to whom the Software is furnished to do
+so, subject to the following conditions:
+
+    * Redistributions of source code must retain the above copyright notice,
+      this list of conditions and the following disclaimers.
+
+    * Redistributions in binary form must reproduce the above copyright notice,
+      this list of conditions and the following disclaimers in the
+      documentation and/or other materials provided with the distribution.
+
+    * Neither the names of the LLVM Team, University of Illinois at
+      Urbana-Champaign, nor the names of its contributors may be used to
+      endorse or promote products derived from this Software without specific
+      prior written permission.
+
+THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
+FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
+CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
+OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
+SOFTWARE.
+
+==============================================================================
+Copyrights and Licenses for Third Party Software Distributed with LLVM:
+==============================================================================
+The LLVM software contains code written by third parties.  Such software will
+have its own individual LICENSE.TXT file in the directory in which it appears.
+This file will describe the copyrights, license, and restrictions which apply
+to that code.
+
+The disclaimer of warranty in the University of Illinois Open Source License
+applies to all code in the LLVM Distribution, and nothing in any of the
+other licenses gives permission to use the names of the LLVM Team or the
+University of Illinois to endorse or promote products derived from this
+Software.
+
+The following pieces of software have additional or alternate copyrights,
+licenses, and/or restrictions:
+
+Program             Directory
+-------             ---------
+Autoconf            llvm/autoconf
+                    llvm/projects/ModuleMaker/autoconf
+                    llvm/projects/sample/autoconf
+CellSPU backend     llvm/lib/Target/CellSPU/README.txt
+Google Test         llvm/utils/unittest/googletest
+OpenBSD regex       llvm/lib/Support/{reg*, COPYRIGHT.regex}
+pyyaml tests        llvm/test/YAMLParser/{*.data, LICENSE.TXT}
diff --git a/tools/bpf/llvm/Makefile.rules b/tools/bpf/llvm/Makefile.rules
new file mode 100644
index 0000000..9689527
--- /dev/null
+++ b/tools/bpf/llvm/Makefile.rules
@@ -0,0 +1,641 @@
+#===-- Makefile.rules - Common make rules for LLVM ---------*- Makefile -*--===#
+#
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+#
+# This file is included by all of the LLVM makefiles.  For details on how to use
+# it properly, please see the document MakefileGuide.html in the docs directory.
+
+# TARGETS: Define standard targets that can be invoked
+
+# Define the various target sets
+RecursiveTargets := all clean clean-all install uninstall
+LocalTargets     := all-local clean-local clean-all-local check-local \
+                    install-local uninstall-local
+TopLevelTargets  := check dist-clean
+UserTargets      := $(RecursiveTargets) $(LocalTargets) $(TopLevelTargets)
+InternalTargets  := preconditions
+
+# INITIALIZATION: Basic things the makefile needs
+
+# Set the VPATH so that we can find source files.
+VPATH=$(PROJ_SRC_DIR)
+
+# Reset the list of suffixes we know how to build.
+.SUFFIXES:
+.SUFFIXES: .c .cpp .cc .h .hpp .o .a
+.SUFFIXES: $(SHLIBEXT) $(SUFFIXES)
+
+# Mark all of these targets as phony to avoid implicit rule search
+.PHONY: $(UserTargets) $(InternalTargets)
+
+# Make sure all the user-target rules are double colon rules and
+# they are defined first.
+
+$(UserTargets)::
+
+# PRECONDITIONS: that which must be built/checked first
+
+SrcMakefiles       := $(filter %Makefile %Makefile.tests,\
+                      $(wildcard $(PROJ_SRC_DIR)/Makefile*))
+ObjMakefiles       := $(subst $(PROJ_SRC_DIR),$(PROJ_OBJ_DIR),$(SrcMakefiles))
+MakefileConfig     := $(PROJ_OBJ_ROOT)/Makefile.config
+MakefileCommon     := $(PROJ_OBJ_ROOT)/Makefile.common
+PreConditions      := $(ObjMakefiles)
+PreConditions      += $(MakefileCommon)
+PreConditions      += $(MakefileConfig)
+
+preconditions: $(PreConditions)
+
+# Make sure the BUILT_SOURCES are built first
+$(filter-out clean clean-local,$(UserTargets)):: $(BUILT_SOURCES)
+
+clean-all-local::
+ifneq ($(strip $(BUILT_SOURCES)),)
+	-$(Verb) $(RM) -f $(BUILT_SOURCES)
+endif
+
+$(BUILT_SOURCES) : $(ObjMakefiles)
+
+ifndef PROJ_MAKEFILE
+PROJ_MAKEFILE := $(PROJ_OBJ_DIR)/Makefile
+endif
+
+# Set up the basic dependencies
+$(UserTargets):: $(PreConditions)
+
+all:: all-local
+clean:: clean-local
+clean-all:: clean-local clean-all-local
+install:: install-local
+uninstall:: uninstall-local
+install-local:: all-local
+
+# VARIABLES: Set up various variables based on configuration data
+
+# Variable for if this make is for a "cleaning" target
+ifneq ($(strip $(filter clean clean-local dist-clean,$(MAKECMDGOALS))),)
+  IS_CLEANING_TARGET=1
+endif
+
+# Variables derived from configuration we are building
+
+CPP.Defines :=
+ifeq ($(ENABLE_OPTIMIZED),1)
+  BuildMode := Release
+  OmitFramePointer := -fomit-frame-pointer
+
+  CXX.Flags += $(OPTIMIZE_OPTION) $(OmitFramePointer)
+  C.Flags   += $(OPTIMIZE_OPTION) $(OmitFramePointer)
+  LD.Flags  += $(OPTIMIZE_OPTION)
+  ifdef DEBUG_SYMBOLS
+    BuildMode := $(BuildMode)+Debug
+    CXX.Flags += -g
+    C.Flags   += -g
+    LD.Flags  += -g
+    KEEP_SYMBOLS := 1
+  endif
+else
+  ifdef NO_DEBUG_SYMBOLS
+    BuildMode := Unoptimized
+    CXX.Flags +=
+    C.Flags   +=
+    LD.Flags  +=
+    KEEP_SYMBOLS := 1
+  else
+    BuildMode := Debug
+    CXX.Flags += -g
+    C.Flags   += -g
+    LD.Flags  += -g
+    KEEP_SYMBOLS := 1
+  endif
+endif
+
+ifeq ($(ENABLE_WERROR),1)
+  CXX.Flags += -Werror
+  C.Flags += -Werror
+endif
+
+ifeq ($(ENABLE_VISIBILITY_INLINES_HIDDEN),1)
+    CXX.Flags += -fvisibility-inlines-hidden
+endif
+
+CXX.Flags += -fno-exceptions
+
+CXX.Flags += -fno-rtti
+
+# If DISABLE_ASSERTIONS=1 is specified (make command line or configured),
+# then disable assertions by defining the appropriate preprocessor symbols.
+ifeq ($(DISABLE_ASSERTIONS),1)
+  CPP.Defines += -DNDEBUG
+else
+  BuildMode := $(BuildMode)+Asserts
+  CPP.Defines += -D_DEBUG
+endif
+
+# If ENABLE_EXPENSIVE_CHECKS=1 is specified (make command line or
+# configured), then enable expensive checks by defining the
+# appropriate preprocessor symbols.
+ifeq ($(ENABLE_EXPENSIVE_CHECKS),1)
+  BuildMode := $(BuildMode)+Checks
+  CPP.Defines += -DXDEBUG
+endif
+
+DOTDIR_TIMESTAMP_COMMAND := $(DATE)
+
+CXX.Flags     += -Woverloaded-virtual
+CPP.BaseFlags += $(CPP.Defines)
+AR.Flags      := cru
+
+# Directory locations
+
+ObjRootDir  := $(PROJ_OBJ_DIR)/$(BuildMode)
+ObjDir      := $(ObjRootDir)
+LibDir      := $(PROJ_OBJ_ROOT)/$(BuildMode)/lib
+ToolDir     := $(PROJ_OBJ_ROOT)/$(BuildMode)/bin
+ExmplDir    := $(PROJ_OBJ_ROOT)/$(BuildMode)/examples
+LLVMLibDir  := $(LLVM_OBJ_ROOT)/$(BuildMode)/lib
+LLVMToolDir := $(LLVM_OBJ_ROOT)/$(BuildMode)/bin
+LLVMExmplDir:= $(LLVM_OBJ_ROOT)/$(BuildMode)/examples
+
+# Locations of shared libraries
+SharedPrefix     := lib
+SharedLibDir     := $(LibDir)
+LLVMSharedLibDir := $(LLVMLibDir)
+
+# Full Paths To Compiled Tools and Utilities
+EchoCmd  := $(ECHO) llvm[$(MAKELEVEL)]:
+
+Echo     := @$(EchoCmd)
+LLVMToolDir := $(shell $(LLVM_CONFIG) --bindir)
+LLVMLibDir := $(shell $(LLVM_CONFIG) --libdir)
+LLVMIncludeDir := $(shell $(LLVM_CONFIG) --includedir)
+ifndef LLVM_TBLGEN
+LLVM_TBLGEN   := $(LLVMToolDir)/llvm-tblgen$(EXEEXT)
+endif
+
+SharedLinkOptions=-shared
+
+ifdef TOOL_VERBOSE
+  C.Flags += -v
+  CXX.Flags += -v
+  LD.Flags += -v
+  VERBOSE := 1
+endif
+
+# Adjust settings for verbose mode
+ifndef VERBOSE
+  Verb := @
+  AR.Flags += >/dev/null 2>/dev/null
+endif
+
+# By default, strip symbol information from executable
+ifndef KEEP_SYMBOLS
+  Strip := $(PLATFORMSTRIPOPTS)
+  StripWarnMsg := "(without symbols)"
+  Install.StripFlag += -s
+endif
+
+ifdef TOOL_NO_EXPORTS
+  DynamicFlags :=
+else
+  DynamicFlag := $(RDYNAMIC)
+endif
+
+# Adjust linker flags for building an executable
+ifdef TOOLNAME
+  LD.Flags += $(RPATH) -Wl,'$$ORIGIN/../lib'
+  LD.Flags += $(RPATH) -Wl,$(ToolDir) $(DynamicFlag)
+endif
+
+# Options To Invoke Tools
+ifdef EXTRA_LD_OPTIONS
+LD.Flags += $(EXTRA_LD_OPTIONS)
+endif
+
+ifndef NO_PEDANTIC
+CompileCommonOpts += -pedantic -Wno-long-long
+endif
+CompileCommonOpts += -Wall -W -Wno-unused-parameter -Wwrite-strings \
+                     $(EXTRA_OPTIONS)
+# Enable cast-qual for C++; the workaround is to use const_cast.
+CXX.Flags += -Wcast-qual
+
+LD.Flags    += -L$(LibDir) -L$(LLVMLibDir)
+
+CPP.BaseFlags += -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS
+# All -I flags should go here, so that they don't confuse llvm-config.
+CPP.Flags     += $(sort -I$(PROJ_OBJ_DIR) -I$(PROJ_SRC_DIR) \
+	         $(patsubst %,-I%/include,\
+	         $(PROJ_OBJ_ROOT) $(PROJ_SRC_ROOT) \
+	         $(LLVM_OBJ_ROOT) $(LLVM_SRC_ROOT))) \
+	         -I$(LLVMIncludeDir) $(CPP.BaseFlags)
+
+Compile.Wrapper :=
+
+Compile.C     = $(Compile.Wrapper) \
+	          $(CC) $(CPP.Flags) $(C.Flags) $(CFLAGS) $(CPPFLAGS) \
+                $(TargetCommonOpts) $(CompileCommonOpts) -c
+Compile.CXX   = $(Compile.Wrapper) \
+	          $(CXX) $(CPP.Flags) $(CXX.Flags) $(CXXFLAGS) $(CPPFLAGS) \
+                $(TargetCommonOpts) $(CompileCommonOpts) -c
+Link          = $(Compile.Wrapper) \
+	          $(CXX) $(CPP.Flags) $(CXX.Flags) $(CXXFLAGS) $(LD.Flags) \
+                $(LDFLAGS) $(TargetCommonOpts)  $(CompileCommonOpts) $(Strip)
+
+ProgInstall   = $(INSTALL) $(Install.StripFlag) -m 0755
+ScriptInstall = $(INSTALL) -m 0755
+DataInstall   = $(INSTALL) -m 0644
+
+TableGen.Flags= -I $(call SYSPATH, $(PROJ_SRC_DIR)) \
+                -I $(call SYSPATH, $(LLVMIncludeDir)) \
+                -I $(call SYSPATH, $(PROJ_SRC_ROOT)/include) \
+                -I $(call SYSPATH, $(PROJ_SRC_ROOT)/lib/Target)
+LLVMTableGen  = $(LLVM_TBLGEN) $(TableGen.Flags)
+
+Archive       = $(AR) $(AR.Flags)
+ifdef RANLIB
+Ranlib        = $(RANLIB)
+else
+Ranlib        = ranlib
+endif
+
+AliasTool     = ln -s
+
+# Get the list of source files and compute object file
+# names from them.
+ifndef SOURCES
+  Sources := $(notdir $(wildcard $(PROJ_SRC_DIR)/*.cpp \
+             $(PROJ_SRC_DIR)/*.cc $(PROJ_SRC_DIR)/*.c))
+else
+  Sources := $(SOURCES)
+endif
+
+ifdef BUILT_SOURCES
+Sources += $(filter %.cpp %.c %.cc,$(BUILT_SOURCES))
+endif
+
+BaseNameSources := $(sort $(basename $(Sources)))
+
+ObjectsO  := $(BaseNameSources:%=$(ObjDir)/%.o)
+
+ECHOPATH := $(Verb)$(ECHO)
+
+# DIRECTORIES: Handle recursive descent of directory structure
+
+# Provide rules to make install dirs. This must be early
+# in the file so they get built before dependencies
+
+$(DESTDIR)$(PROJ_bindir)::
+	$(Verb) $(MKDIR) $@
+
+# To create other directories, as needed, and timestamp their creation
+%/.dir:
+	$(Verb) $(MKDIR) $* > /dev/null
+	$(Verb) $(DOTDIR_TIMESTAMP_COMMAND) > $@
+
+.PRECIOUS: $(ObjDir)/.dir $(LibDir)/.dir $(ToolDir)/.dir $(ExmplDir)/.dir
+.PRECIOUS: $(LLVMLibDir)/.dir $(LLVMToolDir)/.dir $(LLVMExmplDir)/.dir
+
+# Handle the DIRS options for sequential construction
+
+SubDirs :=
+ifdef DIRS
+SubDirs += $(DIRS)
+
+ifneq ($(PROJ_SRC_ROOT),$(PROJ_OBJ_ROOT))
+$(RecursiveTargets)::
+	$(Verb) for dir in $(DIRS); do \
+	  if ([ ! -f $$dir/Makefile ] || \
+	      command test $$dir/Makefile -ot $(PROJ_SRC_DIR)/$$dir/Makefile ); then \
+	    $(MKDIR) $$dir; \
+	    $(CP) $(PROJ_SRC_DIR)/$$dir/Makefile $$dir/Makefile; \
+	  fi; \
+	  ($(MAKE) -C $$dir $@ ) || exit 1; \
+	done
+else
+$(RecursiveTargets)::
+	$(Verb) for dir in $(DIRS); do \
+	  ($(MAKE) -C $$dir $@ ) || exit 1; \
+	done
+endif
+
+endif
+
+# Handle the PARALLEL_DIRS options for parallel construction
+ifdef PARALLEL_DIRS
+
+SubDirs += $(PARALLEL_DIRS)
+
+# Unfortunately, this list must be maintained if new recursive targets are added
+all      :: $(addsuffix /.makeall      ,$(PARALLEL_DIRS))
+clean    :: $(addsuffix /.makeclean    ,$(PARALLEL_DIRS))
+clean-all:: $(addsuffix /.makeclean-all,$(PARALLEL_DIRS))
+install  :: $(addsuffix /.makeinstall  ,$(PARALLEL_DIRS))
+uninstall:: $(addsuffix /.makeuninstall,$(PARALLEL_DIRS))
+
+ParallelTargets := $(foreach T,$(RecursiveTargets),%/.make$(T))
+
+$(ParallelTargets) :
+	$(Verb) \
+	  SD=$(PROJ_SRC_DIR)/$(@D); \
+	  DD=$(@D); \
+	  if [ ! -f $$SD/Makefile ]; then \
+	    SD=$(@D); \
+	    DD=$(notdir $(@D)); \
+	  fi; \
+	  if ([ ! -f $$DD/Makefile ] || \
+	            command test $$DD/Makefile -ot \
+                      $$SD/Makefile ); then \
+	  $(MKDIR) $$DD; \
+	  $(CP) $$SD/Makefile $$DD/Makefile; \
+	fi; \
+	$(MAKE) -C $$DD $(subst $(@D)/.make,,$@)
+endif
+
+# Set up variables for building libraries
+
+# Define various command line options pertaining to the
+# libraries needed when linking. There are "Proj" libs
+# (defined by the user's project) and "LLVM" libs (defined
+# by the LLVM project).
+
+ifdef USEDLIBS
+ProjLibsOptions := $(patsubst %.a.o, -l%, $(addsuffix .o, $(USEDLIBS)))
+ProjLibsOptions := $(patsubst %.o, $(LibDir)/%.o,  $(ProjLibsOptions))
+ProjUsedLibs    := $(patsubst %.a.o, lib%.a, $(addsuffix .o, $(USEDLIBS)))
+ProjLibsPaths   := $(addprefix $(LibDir)/,$(ProjUsedLibs))
+endif
+
+ifdef LLVMLIBS
+LLVMLibsOptions := $(patsubst %.a.o, -l%, $(addsuffix .o, $(LLVMLIBS)))
+LLVMLibsOptions := $(patsubst %.o, $(LLVMLibDir)/%.o, $(LLVMLibsOptions))
+LLVMUsedLibs    := $(patsubst %.a.o, lib%.a, $(addsuffix .o, $(LLVMLIBS)))
+LLVMLibsPaths   := $(addprefix $(LLVMLibDir)/,$(LLVMUsedLibs))
+endif
+
+ifndef IS_CLEANING_TARGET
+ifdef LINK_COMPONENTS
+
+LLVMConfigLibs := $(shell $(LLVM_CONFIG) --libs $(LINK_COMPONENTS) || echo Error)
+ifeq ($(LLVMConfigLibs),Error)
+$(error llvm-config --libs failed)
+endif
+LLVMLibsOptions += $(LLVMConfigLibs)
+LLVMConfigLibfiles := $(shell $(LLVM_CONFIG) --libfiles $(LINK_COMPONENTS) || echo Error)
+ifeq ($(LLVMConfigLibfiles),Error)
+$(error llvm-config --libfiles failed)
+endif
+LLVMLibsPaths += $(LLVMConfigLibfiles)
+
+endif
+endif
+
+# Library Build Rules: Four ways to build a library
+
+# if we're building a library ...
+ifdef LIBRARYNAME
+
+# Make sure there isn't any extraneous whitespace on the LIBRARYNAME option
+LIBRARYNAME := $(strip $(LIBRARYNAME))
+BaseLibName.A  := lib$(LIBRARYNAME).a
+BaseLibName.SO := $(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)
+LibName.A  := $(LibDir)/$(BaseLibName.A)
+LibName.SO := $(SharedLibDir)/$(BaseLibName.SO)
+LibName.O  := $(LibDir)/$(LIBRARYNAME).o
+
+# Library Targets:
+#   If neither BUILD_ARCHIVE or LOADABLE_MODULE are specified, default to
+#   building an archive.
+ifndef NO_BUILD_ARCHIVE
+ifndef BUILD_ARCHIVE
+ifndef LOADABLE_MODULE
+BUILD_ARCHIVE = 1
+endif
+endif
+endif
+
+# Archive Library Targets:
+#   If the user wanted a regular archive library built,
+#   then we provide targets for building them.
+ifdef BUILD_ARCHIVE
+
+all-local:: $(LibName.A)
+
+$(LibName.A): $(ObjectsO) $(LibDir)/.dir
+	$(Echo) Building $(BuildMode) Archive Library $(notdir $@)
+	-$(Verb) $(RM) -f $@
+	$(Verb) $(Archive) $@ $(ObjectsO)
+	$(Verb) $(Ranlib) $@
+
+clean-local::
+ifneq ($(strip $(LibName.A)),)
+	-$(Verb) $(RM) -f $(LibName.A)
+endif
+
+install-local::
+	$(Echo) Install circumvented with NO_INSTALL
+uninstall-local::
+	$(Echo) Uninstall circumvented with NO_INSTALL
+endif
+
+# endif LIBRARYNAME
+endif
+
+# Tool Build Rules: Build executable tool based on TOOLNAME option
+
+ifdef TOOLNAME
+
+# Set up variables for building a tool.
+TOOLEXENAME := $(strip $(TOOLNAME))$(EXEEXT)
+ToolBuildPath   := $(ToolDir)/$(TOOLEXENAME)
+
+# Provide targets for building the tools
+all-local:: $(ToolBuildPath)
+
+clean-local::
+ifneq ($(strip $(ToolBuildPath)),)
+	-$(Verb) $(RM) -f $(ToolBuildPath)
+endif
+
+$(ToolBuildPath): $(ToolDir)/.dir
+
+$(ToolBuildPath): $(ObjectsO) $(ProjLibsPaths) $(LLVMLibsPaths)
+	$(Echo) Linking $(BuildMode) executable $(TOOLNAME) $(StripWarnMsg)
+	$(Verb) $(Link) -o $@ $(TOOLLINKOPTS) $(ObjectsO) $(ProjLibsOptions) \
+	$(LLVMLibsOptions) $(ExtraLibs) $(TOOLLINKOPTSB) $(LIBS)
+	$(Echo) ======= Finished Linking $(BuildMode) Executable $(TOOLNAME) \
+          $(StripWarnMsg)
+
+ifdef NO_INSTALL
+install-local::
+	$(Echo) Install circumvented with NO_INSTALL
+uninstall-local::
+	$(Echo) Uninstall circumvented with NO_INSTALL
+else
+
+ToolBinDir = $(DESTDIR)$(PROJ_bindir)
+DestTool = $(ToolBinDir)/$(program_prefix)$(TOOLEXENAME)
+
+install-local:: $(DestTool)
+
+$(DestTool): $(ToolBuildPath)
+	$(Echo) Installing $(BuildMode) $(DestTool)
+	$(Verb) $(MKDIR) $(ToolBinDir)
+	$(Verb) $(ProgInstall) $(ToolBuildPath) $(DestTool)
+
+uninstall-local::
+	$(Echo) Uninstalling $(BuildMode) $(DestTool)
+	-$(Verb) $(RM) -f $(DestTool)
+
+endif
+endif
+
+# Create .o files in the ObjDir directory from the .cpp and .c files...
+
+DEPEND_OPTIONS = -MMD -MP -MF "$(ObjDir)/$*.d.tmp" \
+         -MT "$(ObjDir)/$*.o" -MT "$(ObjDir)/$*.d"
+
+# If the build succeeded, move the dependency file over, otherwise
+# remove it.
+DEPEND_MOVEFILE = then $(MV) -f "$(ObjDir)/$*.d.tmp" "$(ObjDir)/$*.d"; \
+                  else $(RM) "$(ObjDir)/$*.d.tmp"; exit 1; fi
+
+$(ObjDir)/%.o: %.cpp $(ObjDir)/.dir $(BUILT_SOURCES) $(PROJ_MAKEFILE)
+	$(Echo) "Compiling $*.cpp for $(BuildMode) build" $(PIC_FLAG)
+	$(Verb) if $(Compile.CXX) $(DEPEND_OPTIONS) $< -o $(ObjDir)/$*.o ; \
+	        $(DEPEND_MOVEFILE)
+
+$(ObjDir)/%.o: %.cc $(ObjDir)/.dir $(BUILT_SOURCES) $(PROJ_MAKEFILE)
+	$(Echo) "Compiling $*.cc for $(BuildMode) build" $(PIC_FLAG)
+	$(Verb) if $(Compile.CXX) $(DEPEND_OPTIONS) $< -o $(ObjDir)/$*.o ; \
+	        $(DEPEND_MOVEFILE)
+
+$(ObjDir)/%.o: %.c $(ObjDir)/.dir $(BUILT_SOURCES) $(PROJ_MAKEFILE)
+	$(Echo) "Compiling $*.c for $(BuildMode) build" $(PIC_FLAG)
+	$(Verb) if $(Compile.C) $(DEPEND_OPTIONS) $< -o $(ObjDir)/$*.o ; \
+	        $(DEPEND_MOVEFILE)
+
+# TABLEGEN: Provide rules for running tblgen to produce *.inc files
+
+ifdef TARGET
+TABLEGEN_INC_FILES_COMMON = 1
+endif
+
+ifdef TABLEGEN_INC_FILES_COMMON
+
+INCFiles := $(filter %.inc,$(BUILT_SOURCES))
+INCTMPFiles := $(INCFiles:%=$(ObjDir)/%.tmp)
+.PRECIOUS: $(INCTMPFiles) $(INCFiles)
+
+# INCFiles rule: All of the tblgen generated files are emitted to
+# $(ObjDir)/%.inc.tmp, instead of emitting them directly to %.inc.  This allows
+# us to only "touch" the real file if the contents of it change.  IOW, if
+# tblgen is modified, all of the .inc.tmp files are regenerated, but no
+# dependencies of the .inc files are, unless the contents of the .inc file
+# changes.
+$(INCFiles) : %.inc : $(ObjDir)/%.inc.tmp
+	$(Verb) $(CMP) -s $@ $< || $(CP) $< $@
+
+endif # TABLEGEN_INC_FILES_COMMON
+
+ifdef TARGET
+
+TDFiles := $(strip $(wildcard $(PROJ_SRC_DIR)/*.td) \
+           $(LLVMIncludeDir)/llvm/Target/Target.td \
+           $(LLVMIncludeDir)/llvm/Target/TargetCallingConv.td \
+           $(LLVMIncludeDir)/llvm/Target/TargetSchedule.td \
+           $(LLVMIncludeDir)/llvm/Target/TargetSelectionDAG.td \
+           $(LLVMIncludeDir)/llvm/CodeGen/ValueTypes.td) \
+           $(wildcard $(LLVMIncludeDir)/llvm/Intrinsics*.td)
+
+# All .inc.tmp files depend on the .td files.
+$(INCTMPFiles) : $(TDFiles)
+
+$(TARGET:%=$(ObjDir)/%GenRegisterInfo.inc.tmp): \
+$(ObjDir)/%GenRegisterInfo.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) register info implementation with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-register-info -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenInstrInfo.inc.tmp): \
+$(ObjDir)/%GenInstrInfo.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) instruction information with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-instr-info -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenAsmWriter.inc.tmp): \
+$(ObjDir)/%GenAsmWriter.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) assembly writer with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-asm-writer -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenAsmMatcher.inc.tmp): \
+$(ObjDir)/%GenAsmMatcher.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) assembly matcher with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-asm-matcher -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenMCCodeEmitter.inc.tmp): \
+$(ObjDir)/%GenMCCodeEmitter.inc.tmp: %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) MC code emitter with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-emitter -mc-emitter -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenCodeEmitter.inc.tmp): \
+$(ObjDir)/%GenCodeEmitter.inc.tmp: %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) code emitter with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-emitter -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenDAGISel.inc.tmp): \
+$(ObjDir)/%GenDAGISel.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) DAG instruction selector implementation with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-dag-isel -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenSubtargetInfo.inc.tmp): \
+$(ObjDir)/%GenSubtargetInfo.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) subtarget information with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-subtarget -o $(call SYSPATH, $@) $<
+
+$(TARGET:%=$(ObjDir)/%GenCallingConv.inc.tmp): \
+$(ObjDir)/%GenCallingConv.inc.tmp : %.td $(ObjDir)/.dir $(LLVM_TBLGEN)
+	$(Echo) "Building $(<F) calling convention information with tblgen"
+	$(Verb) $(LLVMTableGen) -gen-callingconv -o $(call SYSPATH, $@) $<
+
+clean-local::
+	-$(Verb) $(RM) -f $(INCFiles)
+
+endif # TARGET
+
+# This rules ensures that header files that are removed still have a rule for
+# which they can be "generated."  This allows make to ignore them and
+# reproduce the dependency lists.
+%.h:: ;
+%.hpp:: ;
+
+# Define clean-local to clean the current directory. Note that this uses a
+# very conservative approach ensuring that empty variables do not cause
+# errors or disastrous removal.
+clean-local::
+ifneq ($(strip $(ObjRootDir)),)
+	-$(Verb) $(RM) -rf $(ObjRootDir)
+endif
+ifneq ($(strip $(SHLIBEXT)),) # Extra paranoia - make real sure SHLIBEXT is set
+	-$(Verb) $(RM) -f *$(SHLIBEXT)
+endif
+
+clean-all-local::
+	-$(Verb) $(RM) -rf Debug Release Profile
+
+
+# DEPENDENCIES: Include the dependency files if we should
+ifndef DISABLE_AUTO_DEPENDENCIES
+
+# If its not one of the cleaning targets
+ifndef IS_CLEANING_TARGET
+
+# Get the list of dependency files
+DependSourceFiles := $(basename $(filter %.cpp %.c %.cc %.m %.mm, $(Sources)))
+DependFiles := $(DependSourceFiles:%=$(PROJ_OBJ_DIR)/$(BuildMode)/%.d)
+
+-include $(DependFiles) ""
+
+endif
+
+endif
+
diff --git a/tools/bpf/llvm/README.txt b/tools/bpf/llvm/README.txt
new file mode 100644
index 0000000..6085afb
--- /dev/null
+++ b/tools/bpf/llvm/README.txt
@@ -0,0 +1,23 @@
+LLVM BPF backend:
+lib/Target/BPF/*.cpp
+
+Links with LLVM 3.2, 3.3 and 3.4
+
+prerequisites:
+apt-get install clang llvm-3.[234]-dev
+
+To build:
+$cd bld
+$make
+if 'llvm-config-3.2' is not found in PATH, build with:
+$make -j4 LLVM_CONFIG=/path_to/llvm-config
+
+To run:
+$clang -O2 -emit-llvm -c file.c -o -|./bld/Debug+Asserts/bin/llc -o file.bpf
+
+'clang' - is unmodified clang used to build x86 code
+'llc' - llvm bit-code to BPF compiler
+file.bpf - BPF binary image, see include/linux/bpf_jit.h
+
+$clang -O2 -emit-llvm -c file.c -o -|llc -filetype=asm -o file.s
+will emit human readable BPF assembler instead.
diff --git a/tools/bpf/llvm/bld/.gitignore b/tools/bpf/llvm/bld/.gitignore
new file mode 100644
index 0000000..c3fc209
--- /dev/null
+++ b/tools/bpf/llvm/bld/.gitignore
@@ -0,0 +1,2 @@
+*.inc
+Debug+Asserts
diff --git a/tools/bpf/llvm/bld/Makefile b/tools/bpf/llvm/bld/Makefile
new file mode 100644
index 0000000..7ac0938
--- /dev/null
+++ b/tools/bpf/llvm/bld/Makefile
@@ -0,0 +1,27 @@
+#===- ./Makefile -------------------------------------------*- Makefile -*--===#
+#
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+ifndef LLVM_CONFIG
+LLVM_CONFIG := llvm-config-3.2
+export LLVM_CONFIG
+endif
+
+LEVEL := .
+
+DIRS := lib tools
+
+include $(LEVEL)/Makefile.config
+
+# Include the main makefile machinery.
+include $(LLVM_SRC_ROOT)/Makefile.rules
+
+# NOTE: This needs to remain as the last target definition in this file so
+# that it gets executed last.
+all::
+	$(Echo) '*****' Completed $(BuildMode) Build
+
+# declare all targets at this level to be serial:
+.NOTPARALLEL:
+
diff --git a/tools/bpf/llvm/bld/Makefile.common b/tools/bpf/llvm/bld/Makefile.common
new file mode 100644
index 0000000..624f7d3
--- /dev/null
+++ b/tools/bpf/llvm/bld/Makefile.common
@@ -0,0 +1,14 @@
+#===-- Makefile.common - Common make rules for LLVM --------*- Makefile -*--===#
+#
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+# Configuration file to set paths specific to local installation of LLVM
+ifndef LLVM_OBJ_ROOT
+include $(LEVEL)/Makefile.config
+else
+include $(LLVM_OBJ_ROOT)/Makefile.config
+endif
+
+# Include all of the build rules used for making LLVM
+include $(LLVM_SRC_ROOT)/Makefile.rules
diff --git a/tools/bpf/llvm/bld/Makefile.config b/tools/bpf/llvm/bld/Makefile.config
new file mode 100644
index 0000000..d8eda05
--- /dev/null
+++ b/tools/bpf/llvm/bld/Makefile.config
@@ -0,0 +1,124 @@
+#===-- Makefile.config - Local configuration for LLVM ------*- Makefile -*--===#
+#
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+#
+# This file is included by Makefile.common.  It defines paths and other
+# values specific to a particular installation of LLVM.
+#
+
+# Directory Configuration
+#	This section of the Makefile determines what is where.  To be
+#	specific, there are several locations that need to be defined:
+#
+#	o LLVM_SRC_ROOT  : The root directory of the LLVM source code.
+#	o LLVM_OBJ_ROOT  : The root directory containing the built LLVM code.
+#
+#	o PROJ_SRC_DIR  : The directory containing the code to build.
+#	o PROJ_SRC_ROOT : The root directory of the code to build.
+#
+#	o PROJ_OBJ_DIR  : The directory in which compiled code will be placed.
+#	o PROJ_OBJ_ROOT : The root directory in which compiled code is placed.
+
+PWD := /bin/pwd
+
+# The macro below is expanded when 'realpath' is not built-in.
+# Built-in 'realpath' is available on GNU Make 3.81.
+realpath = $(shell cd $(1); $(PWD))
+
+PROJ_OBJ_DIR  := $(call realpath, .)
+PROJ_OBJ_ROOT := $(call realpath, $(PROJ_OBJ_DIR)/$(LEVEL))
+
+LLVM_SRC_ROOT   := $(call realpath, $(PROJ_OBJ_DIR)/$(LEVEL)/..)
+LLVM_OBJ_ROOT   := $(call realpath, $(PROJ_OBJ_DIR)/$(LEVEL))
+PROJ_SRC_ROOT   := $(LLVM_SRC_ROOT)
+PROJ_SRC_DIR    := $(LLVM_SRC_ROOT)$(patsubst $(PROJ_OBJ_ROOT)%,%,$(PROJ_OBJ_DIR))
+
+prefix          := /usr/local
+PROJ_prefix     := $(prefix)
+program_prefix  := 
+
+PROJ_bindir     := $(PROJ_prefix)/bin
+
+# Extra options to compile LLVM with
+EXTRA_OPTIONS=
+
+# Extra options to link LLVM with
+EXTRA_LD_OPTIONS=
+
+# Path to the C++ compiler to use.  This is an optional setting, which defaults
+# to whatever your gmake defaults to.
+CXX = g++
+
+# Path to the CC binary, which use used by testcases for native builds.
+CC := gcc
+
+# Linker flags.
+LDFLAGS+=
+
+# Path to the library archiver program.
+AR_PATH = ar
+AR = ar
+
+# The pathnames of the programs we require to build
+CMP        := /usr/bin/cmp
+CP         := /bin/cp
+DATE       := /bin/date
+INSTALL    := /usr/bin/install -c
+MKDIR      := mkdir -p
+MV         := /bin/mv
+RANLIB     := ranlib
+RM         := /bin/rm
+
+LIBS       := -lncurses -lpthread -ldl -lm
+
+# Targets that we should build
+TARGETS_TO_BUILD=BPF 
+
+# What to pass as rpath flag to g++
+RPATH := -Wl,-R
+
+# What to pass as -rdynamic flag to g++
+RDYNAMIC := -Wl,-export-dynamic
+
+# When ENABLE_WERROR is enabled, we'll pass -Werror on the command line
+ENABLE_WERROR = 0
+
+# When ENABLE_OPTIMIZED is enabled, LLVM code is optimized and output is put
+# into the "Release" directories. Otherwise, LLVM code is not optimized and
+# output is put in the "Debug" directories.
+#ENABLE_OPTIMIZED = 1
+
+# When DISABLE_ASSERTIONS is enabled, builds of all of the LLVM code will
+# exclude assertion checks, otherwise they are included.
+#DISABLE_ASSERTIONS = 1
+
+# When DEBUG_SYMBOLS is enabled, the compiler libraries will retain debug
+# symbols.
+#DEBUG_SYMBOLS = 1
+
+# When KEEP_SYMBOLS is enabled, installed executables will never have their
+# symbols stripped.
+#KEEP_SYMBOLS = 1
+
+# The compiler flags to use for optimized builds.
+OPTIMIZE_OPTION := -O3
+
+# Use -fvisibility-inlines-hidden?
+ENABLE_VISIBILITY_INLINES_HIDDEN := 1
+
+# This option tells the Makefiles to produce verbose output.
+# It essentially prints the commands that make is executing
+#VERBOSE = 1
+
+# Shared library extension for host platform.
+SHLIBEXT = .so
+
+# Executable file extension for host platform.
+EXEEXT = 
+
+# Things we just assume are "there"
+ECHO := echo
+
+SYSPATH = $(1)
+
diff --git a/tools/bpf/llvm/bld/include/llvm/Config/AsmParsers.def b/tools/bpf/llvm/bld/include/llvm/Config/AsmParsers.def
new file mode 100644
index 0000000..9efd8f4
--- /dev/null
+++ b/tools/bpf/llvm/bld/include/llvm/Config/AsmParsers.def
@@ -0,0 +1,8 @@
+/*===- llvm/Config/AsmParsers.def - LLVM Assembly Parsers -------*- C++ -*-===*\
+|* This file is distributed under the University of Illinois Open Source      *|
+|* License. See LICENSE.TXT for details.                                      *|
+\*===----------------------------------------------------------------------===*/
+#ifndef LLVM_ASM_PARSER
+#  error Please define the macro LLVM_ASM_PARSER(TargetName)
+#endif
+#undef LLVM_ASM_PARSER
diff --git a/tools/bpf/llvm/bld/include/llvm/Config/AsmPrinters.def b/tools/bpf/llvm/bld/include/llvm/Config/AsmPrinters.def
new file mode 100644
index 0000000..f212afa
--- /dev/null
+++ b/tools/bpf/llvm/bld/include/llvm/Config/AsmPrinters.def
@@ -0,0 +1,9 @@
+/*===- llvm/Config/AsmPrinters.def - LLVM Assembly Printers -----*- C++ -*-===*\
+|* This file is distributed under the University of Illinois Open Source      *|
+|* License. See LICENSE.TXT for details.                                      *|
+\*===----------------------------------------------------------------------===*/
+#ifndef LLVM_ASM_PRINTER
+#  error Please define the macro LLVM_ASM_PRINTER(TargetName)
+#endif
+LLVM_ASM_PRINTER(BPF) 
+#undef LLVM_ASM_PRINTER
diff --git a/tools/bpf/llvm/bld/include/llvm/Config/Disassemblers.def b/tools/bpf/llvm/bld/include/llvm/Config/Disassemblers.def
new file mode 100644
index 0000000..527473f
--- /dev/null
+++ b/tools/bpf/llvm/bld/include/llvm/Config/Disassemblers.def
@@ -0,0 +1,8 @@
+/*===- llvm/Config/Disassemblers.def - LLVM Assembly Parsers ----*- C++ -*-===*\
+|* This file is distributed under the University of Illinois Open Source      *|
+|* License. See LICENSE.TXT for details.                                      *|
+\*===----------------------------------------------------------------------===*/
+#ifndef LLVM_DISASSEMBLER
+#  error Please define the macro LLVM_DISASSEMBLER(TargetName)
+#endif
+#undef LLVM_DISASSEMBLER
diff --git a/tools/bpf/llvm/bld/include/llvm/Config/Targets.def b/tools/bpf/llvm/bld/include/llvm/Config/Targets.def
new file mode 100644
index 0000000..cb2852c
--- /dev/null
+++ b/tools/bpf/llvm/bld/include/llvm/Config/Targets.def
@@ -0,0 +1,9 @@
+/*===- llvm/Config/Targets.def - LLVM Target Architectures ------*- C++ -*-===*\
+|* This file is distributed under the University of Illinois Open Source      *|
+|* License. See LICENSE.TXT for details.                                      *|
+\*===----------------------------------------------------------------------===*/
+#ifndef LLVM_TARGET
+#  error Please define the macro LLVM_TARGET(TargetName)
+#endif
+LLVM_TARGET(BPF) 
+#undef LLVM_TARGET
diff --git a/tools/bpf/llvm/bld/include/llvm/Support/DataTypes.h b/tools/bpf/llvm/bld/include/llvm/Support/DataTypes.h
new file mode 100644
index 0000000..81328a6
--- /dev/null
+++ b/tools/bpf/llvm/bld/include/llvm/Support/DataTypes.h
@@ -0,0 +1,96 @@
+/* include/llvm/Support/DataTypes.h.  Generated from DataTypes.h.in by configure.  */
+/*===-- include/Support/DataTypes.h - Define fixed size types -----*- C -*-===*\
+|*                                                                            *|
+|*                     The LLVM Compiler Infrastructure                       *|
+|*                                                                            *|
+|* This file is distributed under the University of Illinois Open Source      *|
+|* License. See LICENSE.TXT for details.                                      *|
+|*                                                                            *|
+|*===----------------------------------------------------------------------===*|
+|*                                                                            *|
+|* This file contains definitions to figure out the size of _HOST_ data types.*|
+|* This file is important because different host OS's define different macros,*|
+|* which makes portability tough.  This file exports the following            *|
+|* definitions:                                                               *|
+|*                                                                            *|
+|*   [u]int(32|64)_t : typedefs for signed and unsigned 32/64 bit system types*|
+|*   [U]INT(8|16|32|64)_(MIN|MAX) : Constants for the min and max values.     *|
+|*                                                                            *|
+|* No library is required when using these functions.                         *|
+|*                                                                            *|
+|*===----------------------------------------------------------------------===*/
+
+/* Please leave this file C-compatible. */
+
+#ifndef SUPPORT_DATATYPES_H
+#define SUPPORT_DATATYPES_H
+
+#define HAVE_SYS_TYPES_H 1
+#define HAVE_INTTYPES_H 1
+#define HAVE_STDINT_H 1
+#define HAVE_UINT64_T 1
+/* #undef HAVE_U_INT64_T */
+
+#ifdef __cplusplus
+#include <cmath>
+#else
+#include <math.h>
+#endif
+
+/* Note that this header's correct operation depends on __STDC_LIMIT_MACROS
+   being defined.  We would define it here, but in order to prevent Bad Things
+   happening when system headers or C++ STL headers include stdint.h before we
+   define it here, we define it on the g++ command line (in Makefile.rules). */
+#if !defined(__STDC_LIMIT_MACROS)
+# error "Must #define __STDC_LIMIT_MACROS before #including Support/DataTypes.h"
+#endif
+
+#if !defined(__STDC_CONSTANT_MACROS)
+# error "Must #define __STDC_CONSTANT_MACROS before " \
+        "#including Support/DataTypes.h"
+#endif
+
+/* Note that <inttypes.h> includes <stdint.h>, if this is a C99 system. */
+#ifdef HAVE_SYS_TYPES_H
+#include <sys/types.h>
+#endif
+
+#ifdef HAVE_INTTYPES_H
+#include <inttypes.h>
+#endif
+
+#ifdef HAVE_STDINT_H
+#include <stdint.h>
+#endif
+
+/* Handle incorrect definition of uint64_t as u_int64_t */
+#ifndef HAVE_UINT64_T
+#ifdef HAVE_U_INT64_T
+typedef u_int64_t uint64_t;
+#else
+# error "Don't have a definition for uint64_t on this platform"
+#endif
+#endif
+
+/* Set defaults for constants which we cannot find. */
+#if !defined(INT64_MAX)
+# define INT64_MAX 9223372036854775807LL
+#endif
+#if !defined(INT64_MIN)
+# define INT64_MIN ((-INT64_MAX)-1)
+#endif
+#if !defined(UINT64_MAX)
+# define UINT64_MAX 0xffffffffffffffffULL
+#endif
+
+#if __GNUC__ > 3
+#define END_WITH_NULL __attribute__((sentinel))
+#else
+#define END_WITH_NULL
+#endif
+
+#ifndef HUGE_VALF
+#define HUGE_VALF (float)HUGE_VAL
+#endif
+
+#endif  /* SUPPORT_DATATYPES_H */
diff --git a/tools/bpf/llvm/bld/lib/Makefile b/tools/bpf/llvm/bld/lib/Makefile
new file mode 100644
index 0000000..5c7e219
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Makefile
@@ -0,0 +1,11 @@
+##===- lib/Makefile ----------------------------------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+LEVEL = ..
+
+include $(LEVEL)/Makefile.config
+
+PARALLEL_DIRS := Target
+
+include $(LEVEL)/Makefile.common
+
diff --git a/tools/bpf/llvm/bld/lib/Target/BPF/InstPrinter/Makefile b/tools/bpf/llvm/bld/lib/Target/BPF/InstPrinter/Makefile
new file mode 100644
index 0000000..d9a4522
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Target/BPF/InstPrinter/Makefile
@@ -0,0 +1,10 @@
+##===- lib/Target/BPF/InstPrinter/Makefile ----------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+LEVEL = ../../../..
+LIBRARYNAME = LLVMBPFAsmPrinter
+
+# Hack: we need to include 'main' BPF target directory to grab private headers
+CPP.Flags += -I$(PROJ_OBJ_DIR)/.. -I$(PROJ_SRC_DIR)/..
+
+include $(LEVEL)/Makefile.common
diff --git a/tools/bpf/llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile b/tools/bpf/llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile
new file mode 100644
index 0000000..5f2e209
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile
@@ -0,0 +1,11 @@
+##===- lib/Target/BPF/TargetDesc/Makefile ----------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+LEVEL = ../../../..
+LIBRARYNAME = LLVMBPFDesc
+
+# Hack: we need to include 'main' target directory to grab private headers
+CPP.Flags += -I$(PROJ_OBJ_DIR)/.. -I$(PROJ_SRC_DIR)/..
+
+include $(LEVEL)/Makefile.common
diff --git a/tools/bpf/llvm/bld/lib/Target/BPF/Makefile b/tools/bpf/llvm/bld/lib/Target/BPF/Makefile
new file mode 100644
index 0000000..14dea1a3
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Target/BPF/Makefile
@@ -0,0 +1,17 @@
+##===- lib/Target/BPF/Makefile ---------------------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+LEVEL = ../../..
+LIBRARYNAME = LLVMBPFCodeGen
+TARGET = BPF
+
+# Make sure that tblgen is run, first thing.
+BUILT_SOURCES = BPFGenRegisterInfo.inc BPFGenInstrInfo.inc \
+		BPFGenAsmWriter.inc BPFGenAsmMatcher.inc BPFGenDAGISel.inc \
+		BPFGenMCCodeEmitter.inc BPFGenSubtargetInfo.inc BPFGenCallingConv.inc
+
+DIRS = InstPrinter TargetInfo MCTargetDesc
+
+include $(LEVEL)/Makefile.common
+
diff --git a/tools/bpf/llvm/bld/lib/Target/BPF/TargetInfo/Makefile b/tools/bpf/llvm/bld/lib/Target/BPF/TargetInfo/Makefile
new file mode 100644
index 0000000..fdf9056
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Target/BPF/TargetInfo/Makefile
@@ -0,0 +1,10 @@
+##===- lib/Target/BPF/TargetInfo/Makefile ----------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+LEVEL = ../../../..
+LIBRARYNAME = LLVMBPFInfo
+
+# Hack: we need to include 'main' target directory to grab private headers
+CPPFLAGS = -I$(PROJ_OBJ_DIR)/.. -I$(PROJ_SRC_DIR)/..
+
+include $(LEVEL)/Makefile.common
diff --git a/tools/bpf/llvm/bld/lib/Target/Makefile b/tools/bpf/llvm/bld/lib/Target/Makefile
new file mode 100644
index 0000000..06e5185
--- /dev/null
+++ b/tools/bpf/llvm/bld/lib/Target/Makefile
@@ -0,0 +1,11 @@
+#===- lib/Target/Makefile ----------------------------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+LEVEL = ../..
+
+include $(LEVEL)/Makefile.config
+
+PARALLEL_DIRS := $(TARGETS_TO_BUILD)
+
+include $(LLVM_SRC_ROOT)/Makefile.rules
diff --git a/tools/bpf/llvm/bld/tools/Makefile b/tools/bpf/llvm/bld/tools/Makefile
new file mode 100644
index 0000000..6613681
--- /dev/null
+++ b/tools/bpf/llvm/bld/tools/Makefile
@@ -0,0 +1,12 @@
+##===- tools/Makefile --------------------------------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+LEVEL := ..
+
+include $(LEVEL)/Makefile.config
+
+DIRS :=
+PARALLEL_DIRS := llc
+
+include $(LEVEL)/Makefile.common
diff --git a/tools/bpf/llvm/bld/tools/llc/Makefile b/tools/bpf/llvm/bld/tools/llc/Makefile
new file mode 100644
index 0000000..499feb0
--- /dev/null
+++ b/tools/bpf/llvm/bld/tools/llc/Makefile
@@ -0,0 +1,15 @@
+#===- tools/llc/Makefile -----------------------------------*- Makefile -*-===##
+# This file is distributed under the University of Illinois Open Source
+# License. See LICENSE.TXT for details.
+
+LEVEL := ../..
+TOOLNAME := llc
+ifneq (,$(filter $(shell $(LLVM_CONFIG) --version),3.3 3.4))
+LINK_COMPONENTS := asmparser asmprinter codegen bitreader core mc selectiondag support target irreader
+else
+LINK_COMPONENTS := asmparser asmprinter codegen bitreader core mc selectiondag support target
+endif
+USEDLIBS := LLVMBPFCodeGen.a LLVMBPFDesc.a LLVMBPFInfo.a LLVMBPFAsmPrinter.a
+
+include $(LEVEL)/Makefile.common
+
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPF.h b/tools/bpf/llvm/lib/Target/BPF/BPF.h
new file mode 100644
index 0000000..7412b51
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPF.h
@@ -0,0 +1,30 @@
+//===-- BPF.h - Top-level interface for BPF representation ----*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef TARGET_BPF_H
+#define TARGET_BPF_H
+#include "llvm/Config/config.h"
+#undef LLVM_NATIVE_TARGET
+#undef LLVM_NATIVE_ASMPRINTER
+#undef LLVM_NATIVE_ASMPARSER
+#undef LLVM_NATIVE_DISASSEMBLER
+#include "MCTargetDesc/BPFBaseInfo.h"
+#include "MCTargetDesc/BPFMCTargetDesc.h"
+#include "llvm/Target/TargetMachine.h"
+
+namespace llvm {
+class FunctionPass;
+class TargetMachine;
+class BPFTargetMachine;
+
+/// createBPFISelDag - This pass converts a legalized DAG into a
+/// BPF-specific DAG, ready for instruction scheduling.
+FunctionPass *createBPFISelDag(BPFTargetMachine &TM);
+
+FunctionPass *createBPFCFGFixup(BPFTargetMachine &TM);
+
+extern Target TheBPFTarget;
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPF.td b/tools/bpf/llvm/lib/Target/BPF/BPF.td
new file mode 100644
index 0000000..867c7f8
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPF.td
@@ -0,0 +1,29 @@
+//===- BPF.td - Describe the BPF Target Machine --------*- tablegen -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+// Target-independent interfaces which we are implementing
+include "llvm/Target/Target.td"
+
+// BPF Subtarget features.
+include "BPFRegisterInfo.td"
+include "BPFCallingConv.td"
+include "BPFInstrInfo.td"
+
+def BPFInstrInfo : InstrInfo;
+
+class Proc<string Name, list<SubtargetFeature> Features>
+ : Processor<Name, NoItineraries, Features>;
+
+def : Proc<"generic", []>;
+
+def BPFInstPrinter : AsmWriter {
+  string AsmWriterClassName  = "InstPrinter";
+  bit isMCAsmWriter = 1;
+}
+
+// Declare the target which we are implementing
+def BPF : Target {
+  let InstructionSet = BPFInstrInfo;
+  let AssemblyWriters = [BPFInstPrinter];
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp
new file mode 100644
index 0000000..9740d87
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp
@@ -0,0 +1,100 @@
+//===-- BPFAsmPrinter.cpp - BPF LLVM assembly writer --------------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains a printer that converts from our internal representation
+// of machine-dependent LLVM code to the BPF assembly language.
+
+#define DEBUG_TYPE "asm-printer"
+#include "BPF.h"
+#include "BPFInstrInfo.h"
+#include "BPFMCInstLower.h"
+#include "BPFTargetMachine.h"
+#include "InstPrinter/BPFInstPrinter.h"
+#include "llvm/Assembly/Writer.h"
+#include "llvm/CodeGen/AsmPrinter.h"
+#include "llvm/CodeGen/MachineModuleInfo.h"
+#include "llvm/CodeGen/MachineFunctionPass.h"
+#include "llvm/CodeGen/MachineConstantPool.h"
+#include "llvm/CodeGen/MachineInstr.h"
+#include "llvm/MC/MCAsmInfo.h"
+#include "llvm/MC/MCInst.h"
+#include "llvm/MC/MCStreamer.h"
+#include "llvm/MC/MCSymbol.h"
+#include "llvm/Target/Mangler.h"
+#include "llvm/Support/TargetRegistry.h"
+#include "llvm/Support/raw_ostream.h"
+using namespace llvm;
+
+namespace {
+  class BPFAsmPrinter : public AsmPrinter {
+  public:
+    explicit BPFAsmPrinter(TargetMachine &TM, MCStreamer &Streamer)
+      : AsmPrinter(TM, Streamer) {}
+
+    virtual const char *getPassName() const {
+      return "BPF Assembly Printer";
+    }
+
+    void printOperand(const MachineInstr *MI, int OpNum,
+                      raw_ostream &O, const char* Modifier = 0);
+    void EmitInstruction(const MachineInstr *MI);
+  private:
+    void customEmitInstruction(const MachineInstr *MI);
+  };
+}
+
+void BPFAsmPrinter::printOperand(const MachineInstr *MI, int OpNum,
+                                  raw_ostream &O, const char *Modifier) {
+  const MachineOperand &MO = MI->getOperand(OpNum);
+
+  switch (MO.getType()) {
+  case MachineOperand::MO_Register:
+    O << BPFInstPrinter::getRegisterName(MO.getReg());
+    break;
+
+  case MachineOperand::MO_Immediate:
+    O << MO.getImm();
+    break;
+
+  case MachineOperand::MO_MachineBasicBlock:
+    O << *MO.getMBB()->getSymbol();
+    break;
+
+  case MachineOperand::MO_GlobalAddress:
+#if LLVM_VERSION_MINOR==4
+      O << *getSymbol(MO.getGlobal());
+#else
+      O << *Mang->getSymbol(MO.getGlobal());
+#endif
+    break;
+
+  default:
+    llvm_unreachable("<unknown operand type>");
+    O << "bug";
+    return;
+  }
+}
+
+void BPFAsmPrinter::customEmitInstruction(const MachineInstr *MI) {
+  BPFMCInstLower MCInstLowering(OutContext, *Mang, *this);
+
+  MCInst TmpInst;
+  MCInstLowering.Lower(MI, TmpInst);
+  OutStreamer.EmitInstruction(TmpInst);
+}
+
+void BPFAsmPrinter::EmitInstruction(const MachineInstr *MI) {
+
+  MachineBasicBlock::const_instr_iterator I = MI;
+  MachineBasicBlock::const_instr_iterator E = MI->getParent()->instr_end();
+
+  do {
+    customEmitInstruction(I++);
+  } while ((I != E) && I->isInsideBundle());
+}
+
+// Force static initialization.
+extern "C" void LLVMInitializeBPFAsmPrinter() {
+  RegisterAsmPrinter<BPFAsmPrinter> X(TheBPFTarget);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp
new file mode 100644
index 0000000..18401ba
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp
@@ -0,0 +1,62 @@
+//===-- BPFCFGFixup.cpp - CFG fixup pass -----------------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#define DEBUG_TYPE "bpf_cfg"
+#include "BPF.h"
+#include "BPFInstrInfo.h"
+#include "BPFSubtarget.h"
+#include "BPFTargetMachine.h"
+#include "BPFSubtarget.h"
+#include "llvm/CodeGen/MachineFunctionPass.h"
+
+using namespace llvm;
+
+namespace {
+
+class BPFCFGFixup : public MachineFunctionPass {
+ private:
+  BPFTargetMachine& QTM;
+  const BPFSubtarget &QST;
+
+  void InvertAndChangeJumpTarget(MachineInstr*, MachineBasicBlock*);
+
+ public:
+  static char ID;
+  BPFCFGFixup(BPFTargetMachine& TM) : MachineFunctionPass(ID),
+                                                  QTM(TM),
+                                                  QST(*TM.getSubtargetImpl()) {}
+
+  const char *getPassName() const {
+    return "BPF RET insn fixup";
+  }
+  bool runOnMachineFunction(MachineFunction &Fn);
+};
+
+char BPFCFGFixup::ID = 0;
+
+bool BPFCFGFixup::runOnMachineFunction(MachineFunction &Fn) {
+
+  // Loop over all of the basic blocks.
+  for (MachineFunction::iterator MBBb = Fn.begin(), MBBe = Fn.end();
+       MBBb != MBBe; ++MBBb) {
+    MachineBasicBlock* MBB = MBBb;
+
+    MachineBasicBlock::iterator MII = MBB->getFirstTerminator();
+    if (MII != MBB->end()) {
+      /* if last insn of this basic block is RET, make this BB last */
+      if (MII->getOpcode() == BPF::RET) {
+        MBBe--;
+        if (MBB != MBBe)
+          MBB->moveAfter(MBBe);
+        break;
+      }
+    }
+  }
+  return true;
+}
+}
+
+FunctionPass *llvm::createBPFCFGFixup(BPFTargetMachine &TM) {
+  return new BPFCFGFixup(TM);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td b/tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td
new file mode 100644
index 0000000..27c327e
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td
@@ -0,0 +1,24 @@
+//===- BPFCallingConv.td - Calling Conventions BPF -------*- tablegen -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This describes the calling conventions for the BPF architectures.
+
+// BPF 64-bit C return-value convention.
+def RetCC_BPF64 : CallingConv<[
+  CCIfType<[i64], CCAssignToReg<[R0]>>
+]>;
+
+// BPF 64-bit C Calling convention.
+def CC_BPF64 : CallingConv<[
+  // Promote i8/i16/i32 args to i64
+  CCIfType<[i8, i16, i32], CCPromoteToType<i64>>,
+
+  // All arguments get passed in integer registers if there is space.
+  CCIfType<[i64], CCAssignToReg<[R1, R2, R3, R4, R5]>>,
+
+  // Alternatively, they are assigned to the stack in 8-byte aligned units.
+  CCAssignToStack<8, 8>
+]>;
+
+def CSR: CalleeSavedRegs<(add R6, R7, R8, R9, R10)>;
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp
new file mode 100644
index 0000000..b263b5f
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp
@@ -0,0 +1,36 @@
+//===-- BPFFrameLowering.cpp - BPF Frame Information --------------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains the BPF implementation of TargetFrameLowering class.
+
+#include "BPFFrameLowering.h"
+#include "BPFInstrInfo.h"
+#include "llvm/CodeGen/MachineFrameInfo.h"
+#include "llvm/CodeGen/MachineFunction.h"
+#include "llvm/CodeGen/MachineInstrBuilder.h"
+#include "llvm/CodeGen/MachineRegisterInfo.h"
+
+using namespace llvm;
+
+bool BPFFrameLowering::hasFP(const MachineFunction &MF) const {
+  return true;
+}
+
+void BPFFrameLowering::emitPrologue(MachineFunction &MF) const {
+}
+
+void BPFFrameLowering::emitEpilogue(MachineFunction &MF,
+                                    MachineBasicBlock &MBB) const {
+}
+
+void BPFFrameLowering::
+processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
+                                     RegScavenger *RS) const {
+  MachineRegisterInfo& MRI = MF.getRegInfo();
+
+  MRI.setPhysRegUnused(BPF::R6);
+  MRI.setPhysRegUnused(BPF::R7);
+  MRI.setPhysRegUnused(BPF::R8);
+  MRI.setPhysRegUnused(BPF::R9);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h b/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h
new file mode 100644
index 0000000..3e3d9ad
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h
@@ -0,0 +1,35 @@
+//===-- BPFFrameLowering.h - Define frame lowering for BPF ---*- C++ -*--===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef BPF_FRAMEINFO_H
+#define BPF_FRAMEINFO_H
+
+#include "BPF.h"
+#include "BPFSubtarget.h"
+#include "llvm/Target/TargetFrameLowering.h"
+
+namespace llvm {
+class BPFSubtarget;
+
+class BPFFrameLowering : public TargetFrameLowering {
+public:
+  explicit BPFFrameLowering(const BPFSubtarget &sti)
+    : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 8, 0) {
+  }
+
+  void emitPrologue(MachineFunction &MF) const;
+  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const;
+
+  bool hasFP(const MachineFunction &MF) const;
+  virtual void processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
+                                                    RegScavenger *RS) const;
+
+  // llvm 3.3 defines it here
+  void eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
+                                     MachineBasicBlock::iterator MI) const {
+    MBB.erase(MI);
+  }
+};
+}
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp
new file mode 100644
index 0000000..85f905b
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp
@@ -0,0 +1,182 @@
+//===-- BPFISelDAGToDAG.cpp - A dag to dag inst selector for BPF --------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file defines an instruction selector for the BPF target.
+
+#define DEBUG_TYPE "bpf-isel"
+#include "BPF.h"
+#include "BPFRegisterInfo.h"
+#include "BPFSubtarget.h"
+#include "BPFTargetMachine.h"
+#include "llvm/Support/CFG.h"
+#include "llvm/CodeGen/MachineConstantPool.h"
+#include "llvm/CodeGen/MachineFunction.h"
+#include "llvm/CodeGen/MachineFrameInfo.h"
+#include "llvm/CodeGen/MachineInstrBuilder.h"
+#include "llvm/CodeGen/MachineRegisterInfo.h"
+#include "llvm/CodeGen/SelectionDAGISel.h"
+#include "llvm/Target/TargetMachine.h"
+#include "llvm/Support/Debug.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/raw_ostream.h"
+using namespace llvm;
+
+// Instruction Selector Implementation
+namespace {
+
+class BPFDAGToDAGISel : public SelectionDAGISel {
+
+  /// TM - Keep a reference to BPFTargetMachine.
+  BPFTargetMachine &TM;
+
+  /// Subtarget - Keep a pointer to the BPFSubtarget around so that we can
+  /// make the right decision when generating code for different targets.
+  const BPFSubtarget &Subtarget;
+
+public:
+  explicit BPFDAGToDAGISel(BPFTargetMachine &tm) :
+  SelectionDAGISel(tm),
+  TM(tm), Subtarget(tm.getSubtarget<BPFSubtarget>()) {}
+
+  // Pass Name
+  virtual const char *getPassName() const {
+    return "BPF DAG->DAG Pattern Instruction Selection";
+  }
+
+private:
+  // Include the pieces autogenerated from the target description.
+  #include "BPFGenDAGISel.inc"
+
+  /// getTargetMachine - Return a reference to the TargetMachine, casted
+  /// to the target-specific type.
+  const BPFTargetMachine &getTargetMachine() {
+    return static_cast<const BPFTargetMachine &>(TM);
+  }
+
+  /// getInstrInfo - Return a reference to the TargetInstrInfo, casted
+  /// to the target-specific type.
+  const BPFInstrInfo *getInstrInfo() {
+    return getTargetMachine().getInstrInfo();
+  }
+
+  SDNode *Select(SDNode *N);
+
+  // Complex Pattern for address selection.
+  bool SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset);
+
+  // getI32Imm - Return a target constant with the specified value, of type i32.
+  inline SDValue getI32Imm(unsigned Imm) {
+    return CurDAG->getTargetConstant(Imm, MVT::i64);
+  }
+};
+
+}
+
+/// ComplexPattern used on BPFInstrInfo
+/// Used on BPF Load/Store instructions
+bool BPFDAGToDAGISel::
+SelectAddr(SDValue Addr, SDValue &Base, SDValue &Offset) {
+  // if Address is FI, get the TargetFrameIndex.
+  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
+    Base   = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
+    Offset = CurDAG->getTargetConstant(0, MVT::i64);
+    return true;
+  }
+
+  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
+      Addr.getOpcode() == ISD::TargetGlobalAddress)
+    return false;
+
+  // Addresses of the form FI+const or FI|const
+  if (CurDAG->isBaseWithConstantOffset(Addr)) {
+    ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
+    if (isInt<32>(CN->getSExtValue())) {
+
+      // If the first operand is a FI, get the TargetFI Node
+      if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>
+                                  (Addr.getOperand(0)))
+        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
+      else
+        Base = Addr.getOperand(0);
+
+      Offset = CurDAG->getTargetConstant(CN->getSExtValue(), MVT::i64);
+      return true;
+    }
+  }
+
+  // Operand is a result from an ADD.
+  if (Addr.getOpcode() == ISD::ADD) {
+    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1))) {
+      if (isInt<32>(CN->getSExtValue())) {
+
+        // If the first operand is a FI, get the TargetFI Node
+        if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>
+                                    (Addr.getOperand(0))) {
+          Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
+        } else {
+          Base = Addr.getOperand(0);
+        }
+
+        Offset = CurDAG->getTargetConstant(CN->getSExtValue(), MVT::i64);
+        return true;
+      }
+    }
+  }
+
+  Base   = Addr;
+  Offset = CurDAG->getTargetConstant(0, MVT::i64);
+  return true;
+}
+
+/// Select instructions not customized! Used for
+/// expanded, promoted and normal instructions
+SDNode* BPFDAGToDAGISel::Select(SDNode *Node) {
+  unsigned Opcode = Node->getOpcode();
+
+  // Dump information about the Node being selected
+  DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");
+
+  // If we have a custom node, we already have selected!
+  if (Node->isMachineOpcode()) {
+    DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
+    return NULL;
+  }
+
+  // tablegen selection should be handled here.
+  switch(Opcode) {
+    default: break;
+
+    case ISD::FrameIndex: {
+        int FI = dyn_cast<FrameIndexSDNode>(Node)->getIndex();
+        EVT VT = Node->getValueType(0);
+        SDValue TFI = CurDAG->getTargetFrameIndex(FI, VT);
+        unsigned Opc = BPF::MOV_rr;
+        if (Node->hasOneUse())
+          return CurDAG->SelectNodeTo(Node, Opc, VT, TFI);
+#if LLVM_VERSION_MINOR==4
+        return CurDAG->getMachineNode(Opc, SDLoc(Node), VT, TFI);
+#else
+        return CurDAG->getMachineNode(Opc, Node->getDebugLoc(), VT, TFI);
+#endif
+
+    }
+  }
+
+  // Select the default instruction
+  SDNode *ResNode = SelectCode(Node);
+
+  DEBUG(errs() << "=> ");
+  if (ResNode == NULL || ResNode == Node)
+    DEBUG(Node->dump(CurDAG));
+  else
+    DEBUG(ResNode->dump(CurDAG));
+  DEBUG(errs() << "\n");
+  return ResNode;
+}
+
+/// createBPFISelDag - This pass converts a legalized DAG into a
+/// BPF-specific DAG, ready for instruction scheduling.
+FunctionPass *llvm::createBPFISelDag(BPFTargetMachine &TM) {
+  return new BPFDAGToDAGISel(TM);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp
new file mode 100644
index 0000000..b065d31
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp
@@ -0,0 +1,676 @@
+//===-- BPFISelLowering.cpp - BPF DAG Lowering Implementation  ----------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file implements the BPFTargetLowering class.
+
+#define DEBUG_TYPE "bpf-lower"
+
+#include "BPFISelLowering.h"
+#include "BPF.h"
+#include "BPFTargetMachine.h"
+#include "BPFSubtarget.h"
+#include "llvm/CodeGen/CallingConvLower.h"
+#include "llvm/CodeGen/MachineFrameInfo.h"
+#include "llvm/CodeGen/MachineFunction.h"
+#include "llvm/CodeGen/MachineInstrBuilder.h"
+#include "llvm/CodeGen/MachineRegisterInfo.h"
+#include "llvm/CodeGen/SelectionDAGISel.h"
+#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
+#include "llvm/CodeGen/ValueTypes.h"
+#include "llvm/Support/CommandLine.h"
+#include "llvm/Support/Debug.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/raw_ostream.h"
+using namespace llvm;
+
+BPFTargetLowering::BPFTargetLowering(BPFTargetMachine &tm) :
+  TargetLowering(tm, new TargetLoweringObjectFileELF()),
+  Subtarget(*tm.getSubtargetImpl()), TM(tm) {
+
+  // Set up the register classes.
+  addRegisterClass(MVT::i64, &BPF::GPRRegClass);
+
+  // Compute derived properties from the register classes
+  computeRegisterProperties();
+
+  setStackPointerRegisterToSaveRestore(BPF::R11);
+
+  setOperationAction(ISD::BR_CC,             MVT::i64, Custom);
+  setOperationAction(ISD::BR_JT,             MVT::Other, Expand);
+  setOperationAction(ISD::BRCOND,            MVT::Other, Expand);
+  setOperationAction(ISD::SETCC,             MVT::i64, Expand);
+  setOperationAction(ISD::SELECT,            MVT::i64, Expand);
+  setOperationAction(ISD::SELECT_CC,         MVT::i64, Custom);
+
+//  setCondCodeAction(ISD::SETLT,             MVT::i64, Expand);
+
+  setOperationAction(ISD::GlobalAddress,     MVT::i64, Custom);
+  /*setOperationAction(ISD::BlockAddress,      MVT::i64, Custom);
+  setOperationAction(ISD::JumpTable,         MVT::i64, Custom);
+  setOperationAction(ISD::ConstantPool,      MVT::i64, Custom);*/
+
+  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64,   Custom);
+  setOperationAction(ISD::STACKSAVE,          MVT::Other, Expand);
+  setOperationAction(ISD::STACKRESTORE,       MVT::Other, Expand);
+
+/*  setOperationAction(ISD::VASTART,            MVT::Other, Custom);
+  setOperationAction(ISD::VAARG,              MVT::Other, Expand);
+  setOperationAction(ISD::VACOPY,             MVT::Other, Expand);
+  setOperationAction(ISD::VAEND,              MVT::Other, Expand);*/
+
+//    setOperationAction(ISD::SDIV,            MVT::i64, Expand);
+//  setOperationAction(ISD::UDIV,            MVT::i64, Expand);
+
+  setOperationAction(ISD::SDIVREM,           MVT::i64, Expand);
+  setOperationAction(ISD::UDIVREM,           MVT::i64, Expand);
+  setOperationAction(ISD::SREM,              MVT::i64, Expand);
+  setOperationAction(ISD::UREM,              MVT::i64, Expand);
+
+//  setOperationAction(ISD::MUL,             MVT::i64, Expand);
+
+  setOperationAction(ISD::MULHU,             MVT::i64, Expand);
+  setOperationAction(ISD::MULHS,             MVT::i64, Expand);
+  setOperationAction(ISD::UMUL_LOHI,         MVT::i64, Expand);
+  setOperationAction(ISD::SMUL_LOHI,         MVT::i64, Expand);
+
+  setOperationAction(ISD::ADDC, MVT::i64, Expand);
+  setOperationAction(ISD::ADDE, MVT::i64, Expand);
+  setOperationAction(ISD::SUBC, MVT::i64, Expand);
+  setOperationAction(ISD::SUBE, MVT::i64, Expand);
+
+  setOperationAction(ISD::ROTR,              MVT::i64, Expand);
+  setOperationAction(ISD::ROTL,              MVT::i64, Expand);
+  setOperationAction(ISD::SHL_PARTS,         MVT::i64, Expand);
+  setOperationAction(ISD::SRL_PARTS,         MVT::i64, Expand);
+  setOperationAction(ISD::SRA_PARTS,         MVT::i64, Expand);
+
+  setOperationAction(ISD::BSWAP,             MVT::i64, Expand);
+  setOperationAction(ISD::CTTZ,              MVT::i64, Custom);
+  setOperationAction(ISD::CTLZ,              MVT::i64, Custom);
+  setOperationAction(ISD::CTTZ_ZERO_UNDEF,   MVT::i64, Custom);
+  setOperationAction(ISD::CTLZ_ZERO_UNDEF,   MVT::i64, Custom);
+  setOperationAction(ISD::CTPOP,             MVT::i64, Expand);
+
+
+  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1,   Expand);
+  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8,   Expand);
+  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16,  Expand);
+  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i32,  Expand);
+
+  // Extended load operations for i1 types must be promoted
+  setLoadExtAction(ISD::EXTLOAD,             MVT::i1,   Promote);
+  setLoadExtAction(ISD::ZEXTLOAD,            MVT::i1,   Promote);
+  setLoadExtAction(ISD::SEXTLOAD,            MVT::i1,   Promote);
+
+  setLoadExtAction(ISD::SEXTLOAD,            MVT::i8,   Expand);
+  setLoadExtAction(ISD::SEXTLOAD,            MVT::i16,   Expand);
+  setLoadExtAction(ISD::SEXTLOAD,            MVT::i32,   Expand);
+
+  // Function alignments (log2)
+  setMinFunctionAlignment(3);
+  setPrefFunctionAlignment(3);
+
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+  MaxStoresPerMemcpy = 128;
+  MaxStoresPerMemcpyOptSize = 128;
+  MaxStoresPerMemset = 128;
+#else
+  maxStoresPerMemcpy = 128;
+  maxStoresPerMemcpyOptSize = 128;
+  maxStoresPerMemset = 128;
+#endif
+}
+
+SDValue BPFTargetLowering::LowerOperation(SDValue Op,
+                                          SelectionDAG &DAG) const {
+  switch (Op.getOpcode()) {
+  case ISD::BR_CC:              return LowerBR_CC(Op, DAG);
+  case ISD::GlobalAddress:      return LowerGlobalAddress(Op, DAG);
+  case ISD::SELECT_CC:          return LowerSELECT_CC(Op, DAG);
+  default:
+    llvm_unreachable("unimplemented operand");
+  }
+}
+
+//                      Calling Convention Implementation
+#include "BPFGenCallingConv.inc"
+
+SDValue
+BPFTargetLowering::LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
+                                        bool isVarArg,
+                                        const SmallVectorImpl<ISD::InputArg>
+                                        &Ins,
+#if LLVM_VERSION_MINOR==4
+                                        SDLoc dl,
+#else
+                                        DebugLoc dl,
+#endif
+                                        SelectionDAG &DAG,
+                                        SmallVectorImpl<SDValue> &InVals)
+                                          const {
+  switch (CallConv) {
+  default:
+    llvm_unreachable("Unsupported calling convention");
+  case CallingConv::C:
+  case CallingConv::Fast:
+    break;
+  }
+
+/// LowerCCCArguments - transform physical registers into virtual registers and
+/// generate load operations for arguments places on the stack.
+  MachineFunction &MF = DAG.getMachineFunction();
+  MachineRegisterInfo &RegInfo = MF.getRegInfo();
+
+  // Assign locations to all of the incoming arguments.
+  SmallVector<CCValAssign, 16> ArgLocs;
+  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
+                 getTargetMachine(), ArgLocs, *DAG.getContext());
+  CCInfo.AnalyzeFormalArguments(Ins, CC_BPF64);
+
+  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
+    CCValAssign &VA = ArgLocs[i];
+    if (VA.isRegLoc()) {
+      // Arguments passed in registers
+      EVT RegVT = VA.getLocVT();
+      switch (RegVT.getSimpleVT().SimpleTy) {
+      default:
+        {
+#ifndef NDEBUG
+          errs() << "LowerFormalArguments Unhandled argument type: "
+               << RegVT.getSimpleVT().SimpleTy << "\n";
+#endif
+          llvm_unreachable(0);
+        }
+      case MVT::i64:
+        unsigned VReg = RegInfo.createVirtualRegister(&BPF::GPRRegClass);
+        RegInfo.addLiveIn(VA.getLocReg(), VReg);
+        SDValue ArgValue = DAG.getCopyFromReg(Chain, dl, VReg, RegVT);
+
+        // If this is an 8/16/32-bit value, it is really passed promoted to 64
+        // bits. Insert an assert[sz]ext to capture this, then truncate to the
+        // right size.
+        if (VA.getLocInfo() == CCValAssign::SExt)
+          ArgValue = DAG.getNode(ISD::AssertSext, dl, RegVT, ArgValue,
+                                 DAG.getValueType(VA.getValVT()));
+        else if (VA.getLocInfo() == CCValAssign::ZExt)
+          ArgValue = DAG.getNode(ISD::AssertZext, dl, RegVT, ArgValue,
+                                 DAG.getValueType(VA.getValVT()));
+
+        if (VA.getLocInfo() != CCValAssign::Full)
+          ArgValue = DAG.getNode(ISD::TRUNCATE, dl, VA.getValVT(), ArgValue);
+
+        InVals.push_back(ArgValue);
+      }
+    } else {
+      assert(VA.isMemLoc());
+      errs() << "Function: " << MF.getName() << " ";
+      MF.getFunction()->getFunctionType()->dump();
+      errs() << "\n";
+      report_fatal_error("too many function args");
+    }
+  }
+
+  if (isVarArg || MF.getFunction()->hasStructRetAttr()) {
+    errs() << "Function: " << MF.getName() << " ";
+    MF.getFunction()->getFunctionType()->dump();
+    errs() << "\n";
+    report_fatal_error("functions with VarArgs or StructRet are not supported");
+  }
+
+  return Chain;
+}
+
+SDValue
+BPFTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
+                              SmallVectorImpl<SDValue> &InVals) const {
+  SelectionDAG &DAG                     = CLI.DAG;
+  SmallVector<ISD::OutputArg, 32> &Outs = CLI.Outs;
+  SmallVector<SDValue, 32> &OutVals     = CLI.OutVals;
+  SmallVector<ISD::InputArg, 32> &Ins   = CLI.Ins;
+  SDValue Chain                         = CLI.Chain;
+  SDValue Callee                        = CLI.Callee;
+  bool &isTailCall                      = CLI.IsTailCall;
+  CallingConv::ID CallConv              = CLI.CallConv;
+  bool isVarArg                         = CLI.IsVarArg;
+
+  // BPF target does not support tail call optimization.
+  isTailCall = false;
+
+  switch (CallConv) {
+  default:
+    report_fatal_error("Unsupported calling convention");
+  case CallingConv::Fast:
+  case CallingConv::C:
+    break;
+  }
+
+/// LowerCCCCallTo - functions arguments are copied from virtual regs to
+/// (physical regs)/(stack frame), CALLSEQ_START and CALLSEQ_END are emitted.
+
+  // Analyze operands of the call, assigning locations to each operand.
+  SmallVector<CCValAssign, 16> ArgLocs;
+  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
+                 getTargetMachine(), ArgLocs, *DAG.getContext());
+
+  CCInfo.AnalyzeCallOperands(Outs, CC_BPF64);
+
+  // Get a count of how many bytes are to be pushed on the stack.
+  unsigned NumBytes = CCInfo.getNextStackOffset();
+
+  // Create local copies for byval args.
+  SmallVector<SDValue, 8> ByValArgs;
+
+  if (Outs.size() >= 6) {
+    errs() << "too many arguments to a function ";
+    Callee.dump();
+    report_fatal_error("too many args\n");
+  }
+
+  for (unsigned i = 0,  e = Outs.size(); i != e; ++i) {
+    ISD::ArgFlagsTy Flags = Outs[i].Flags;
+    if (!Flags.isByVal())
+      continue;
+
+    Callee.dump();
+    report_fatal_error("cannot pass by value");
+  }
+
+  Chain = DAG.getCALLSEQ_START(Chain, DAG.getConstant(NumBytes,
+                                                      getPointerTy(), true)
+#if LLVM_VERSION_MINOR==4
+                                                      , CLI.DL
+#endif
+                                                      );
+
+  SmallVector<std::pair<unsigned, SDValue>, 4> RegsToPass;
+  SDValue StackPtr;
+
+  // Walk the register/memloc assignments, inserting copies/loads.
+  for (unsigned i = 0, j = 0, e = ArgLocs.size(); i != e; ++i) {
+    CCValAssign &VA = ArgLocs[i];
+    SDValue Arg = OutVals[i];
+    ISD::ArgFlagsTy Flags = Outs[i].Flags;
+
+
+    // Promote the value if needed.
+    switch (VA.getLocInfo()) {
+      default: llvm_unreachable("Unknown loc info!");
+      case CCValAssign::Full: break;
+      case CCValAssign::SExt:
+        Arg = DAG.getNode(ISD::SIGN_EXTEND, CLI.DL, VA.getLocVT(), Arg);
+        break;
+      case CCValAssign::ZExt:
+        Arg = DAG.getNode(ISD::ZERO_EXTEND, CLI.DL, VA.getLocVT(), Arg);
+        break;
+      case CCValAssign::AExt:
+        Arg = DAG.getNode(ISD::ANY_EXTEND, CLI.DL, VA.getLocVT(), Arg);
+        break;
+    }
+
+    // Use local copy if it is a byval arg.
+    if (Flags.isByVal())
+      Arg = ByValArgs[j++];
+
+    // Arguments that can be passed on register must be kept at RegsToPass
+    // vector
+    if (VA.isRegLoc()) {
+      RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
+    } else {
+      llvm_unreachable("call arg pass bug");
+    }
+  }
+
+  SDValue InFlag;
+
+  // Build a sequence of copy-to-reg nodes chained together with token chain and
+  // flag operands which copy the outgoing args into registers.  The InFlag in
+  // necessary since all emitted instructions must be stuck together.
+  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
+    Chain = DAG.getCopyToReg(Chain, CLI.DL, RegsToPass[i].first,
+                             RegsToPass[i].second, InFlag);
+    InFlag = Chain.getValue(1);
+  }
+
+  // If the callee is a GlobalAddress node (quite common, every direct call is)
+  // turn it into a TargetGlobalAddress node so that legalize doesn't hack it.
+  // Likewise ExternalSymbol -> TargetExternalSymbol.
+  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
+    Callee = DAG.getTargetGlobalAddress(G->getGlobal(), CLI.DL, getPointerTy(), G->getOffset()/*0*/,
+                                        0);
+  } else if (ExternalSymbolSDNode *E = dyn_cast<ExternalSymbolSDNode>(Callee)) {
+    Callee = DAG.getTargetExternalSymbol(E->getSymbol(), getPointerTy(),
+                                         0);
+  }
+
+  // Returns a chain & a flag for retval copy to use.
+  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
+  SmallVector<SDValue, 8> Ops;
+  Ops.push_back(Chain);
+  Ops.push_back(Callee);
+
+  // Add argument registers to the end of the list so that they are
+  // known live into the call.
+  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
+    Ops.push_back(DAG.getRegister(RegsToPass[i].first,
+                                  RegsToPass[i].second.getValueType()));
+
+  if (InFlag.getNode())
+    Ops.push_back(InFlag);
+
+  Chain = DAG.getNode(BPFISD::CALL, CLI.DL, NodeTys, &Ops[0], Ops.size());
+  InFlag = Chain.getValue(1);
+
+  // Create the CALLSEQ_END node.
+  Chain = DAG.getCALLSEQ_END(Chain,
+                             DAG.getConstant(NumBytes, getPointerTy(), true),
+                             DAG.getConstant(0, getPointerTy(), true),
+                             InFlag
+#if LLVM_VERSION_MINOR==4
+                             , CLI.DL
+#endif
+                             );
+  InFlag = Chain.getValue(1);
+
+  // Handle result values, copying them out of physregs into vregs that we
+  // return.
+  return LowerCallResult(Chain, InFlag, CallConv, isVarArg, Ins, CLI.DL,
+                         DAG, InVals);
+}
+
+SDValue
+BPFTargetLowering::LowerReturn(SDValue Chain,
+                               CallingConv::ID CallConv, bool isVarArg,
+                               const SmallVectorImpl<ISD::OutputArg> &Outs,
+                               const SmallVectorImpl<SDValue> &OutVals,
+#if LLVM_VERSION_MINOR==4
+                               SDLoc dl,
+#else
+                               DebugLoc dl,
+#endif
+                               SelectionDAG &DAG) const {
+
+  // CCValAssign - represent the assignment of the return value to a location
+  SmallVector<CCValAssign, 16> RVLocs;
+
+  // CCState - Info about the registers and stack slot.
+  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
+                 getTargetMachine(), RVLocs, *DAG.getContext());
+
+  // Analize return values.
+  CCInfo.AnalyzeReturn(Outs, RetCC_BPF64);
+
+  // If this is the first return lowered for this function, add the regs to the
+  // liveout set for the function.
+#if LLVM_VERSION_MINOR==2
+  if (DAG.getMachineFunction().getRegInfo().liveout_empty()) {
+    for (unsigned i = 0; i != RVLocs.size(); ++i)
+      if (RVLocs[i].isRegLoc())
+        DAG.getMachineFunction().getRegInfo().addLiveOut(RVLocs[i].getLocReg());
+  }
+#endif
+
+  SDValue Flag;
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+  SmallVector<SDValue, 4> RetOps(1, Chain);
+#endif
+
+  // Copy the result values into the output registers.
+  for (unsigned i = 0; i != RVLocs.size(); ++i) {
+    CCValAssign &VA = RVLocs[i];
+    assert(VA.isRegLoc() && "Can only return in registers!");
+
+    Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(),
+                             OutVals[i], Flag);
+
+    // Guarantee that all emitted copies are stuck together,
+    // avoiding something bad.
+    Flag = Chain.getValue(1);
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
+#endif
+  }
+
+  if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
+    errs() << "Function: " << DAG.getMachineFunction().getName() << " ";
+    DAG.getMachineFunction().getFunction()->getFunctionType()->dump();
+    errs() << "\n";
+    report_fatal_error("BPF doesn't support struct return");
+  }
+
+  unsigned Opc = BPFISD::RET_FLAG;
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+  RetOps[0] = Chain;  // Update chain.
+
+  // Add the flag if we have it.
+  if (Flag.getNode())
+    RetOps.push_back(Flag);
+
+  return DAG.getNode(Opc, dl, MVT::Other, &RetOps[0], RetOps.size());
+#else
+  if (Flag.getNode())
+    return DAG.getNode(Opc, dl, MVT::Other, Chain, Flag);
+
+  // Return Void
+  return DAG.getNode(Opc, dl, MVT::Other, Chain);
+#endif
+}
+
+/// LowerCallResult - Lower the result values of a call into the
+/// appropriate copies out of appropriate physical registers.
+SDValue
+BPFTargetLowering::LowerCallResult(SDValue Chain, SDValue InFlag,
+                                   CallingConv::ID CallConv, bool isVarArg,
+                                   const SmallVectorImpl<ISD::InputArg> &Ins,
+#if LLVM_VERSION_MINOR==4
+                                   SDLoc dl,
+#else
+                                   DebugLoc dl,
+#endif
+                                   SelectionDAG &DAG,
+                                   SmallVectorImpl<SDValue> &InVals) const {
+
+  // Assign locations to each value returned by this call.
+  SmallVector<CCValAssign, 16> RVLocs;
+  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
+                 getTargetMachine(), RVLocs, *DAG.getContext());
+
+  CCInfo.AnalyzeCallResult(Ins, RetCC_BPF64);
+
+  // Copy all of the result registers out of their specified physreg.
+  for (unsigned i = 0; i != RVLocs.size(); ++i) {
+    Chain = DAG.getCopyFromReg(Chain, dl, RVLocs[i].getLocReg(),
+                               RVLocs[i].getValVT(), InFlag).getValue(1);
+    InFlag = Chain.getValue(2);
+    InVals.push_back(Chain.getValue(0));
+  }
+
+  return Chain;
+}
+
+static bool NegateCC(SDValue &LHS, SDValue &RHS, ISD::CondCode &CC)
+{
+  switch (CC) {
+  default:
+    return false;
+  case ISD::SETULT:
+    CC = ISD::SETUGT;
+    std::swap(LHS, RHS);
+    return true;
+  case ISD::SETULE:
+    CC = ISD::SETUGE;
+    std::swap(LHS, RHS);
+    return true;
+  case ISD::SETLT:
+    CC = ISD::SETGT;
+    std::swap(LHS, RHS);
+    return true;
+  case ISD::SETLE:
+    CC = ISD::SETGE;
+    std::swap(LHS, RHS);
+    return true;
+  }
+}
+
+SDValue BPFTargetLowering::LowerBR_CC(SDValue Op,
+                                      SelectionDAG &DAG) const {
+  SDValue Chain  = Op.getOperand(0);
+  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(1))->get();
+  SDValue LHS   = Op.getOperand(2);
+  SDValue RHS   = Op.getOperand(3);
+  SDValue Dest  = Op.getOperand(4);
+#if LLVM_VERSION_MINOR==4
+  SDLoc    dl(Op);
+#else
+  DebugLoc dl   = Op.getDebugLoc();
+#endif
+
+  NegateCC(LHS, RHS, CC);
+
+  return DAG.getNode(BPFISD::BR_CC, dl, Op.getValueType(),
+                     Chain, LHS, RHS, DAG.getConstant(CC, MVT::i64), Dest);
+}
+
+SDValue BPFTargetLowering::LowerSELECT_CC(SDValue Op,
+                                          SelectionDAG &DAG) const {
+  SDValue LHS    = Op.getOperand(0);
+  SDValue RHS    = Op.getOperand(1);
+  SDValue TrueV  = Op.getOperand(2);
+  SDValue FalseV = Op.getOperand(3);
+  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(4))->get();
+#if LLVM_VERSION_MINOR==4
+  SDLoc    dl(Op);
+#else
+  DebugLoc dl    = Op.getDebugLoc();
+#endif
+
+  NegateCC(LHS, RHS, CC);
+
+  SDValue TargetCC = DAG.getConstant(CC, MVT::i64);
+
+  SDVTList VTs = DAG.getVTList(Op.getValueType(), MVT::Glue);
+  SmallVector<SDValue, 5> Ops;
+  Ops.push_back(LHS);
+  Ops.push_back(RHS);
+  Ops.push_back(TargetCC);
+  Ops.push_back(TrueV);
+  Ops.push_back(FalseV);
+
+  SDValue sel = DAG.getNode(BPFISD::SELECT_CC, dl, VTs, &Ops[0], Ops.size());
+  DEBUG(errs() << "LowerSELECT_CC:\n"; sel.dumpr(); errs() << "\n");
+  return sel;
+}
+
+const char *BPFTargetLowering::getTargetNodeName(unsigned Opcode) const {
+  switch (Opcode) {
+  default: return NULL;
+  case BPFISD::ADJDYNALLOC:        return "BPFISD::ADJDYNALLOC";
+  case BPFISD::RET_FLAG:           return "BPFISD::RET_FLAG";
+  case BPFISD::CALL:               return "BPFISD::CALL";
+  case BPFISD::SELECT_CC:          return "BPFISD::SELECT_CC";
+  case BPFISD::BR_CC:              return "BPFISD::BR_CC";
+  case BPFISD::Wrapper:            return "BPFISD::Wrapper";
+  }
+}
+
+SDValue BPFTargetLowering::LowerGlobalAddress(SDValue Op,
+                                              SelectionDAG &DAG) const {
+  Op.dump();
+  report_fatal_error("LowerGlobalAddress: BPF cannot access global variables");
+  return SDValue();
+}
+
+MachineBasicBlock*
+BPFTargetLowering::EmitInstrWithCustomInserter(MachineInstr *MI,
+                                               MachineBasicBlock *BB) const {
+  unsigned Opc = MI->getOpcode();
+
+  const TargetInstrInfo &TII = *getTargetMachine().getInstrInfo();
+  DebugLoc dl = MI->getDebugLoc();
+
+  assert(Opc == BPF::Select && "Unexpected instr type to insert");
+
+  // To "insert" a SELECT instruction, we actually have to insert the diamond
+  // control-flow pattern.  The incoming instruction knows the destination vreg
+  // to set, the condition code register to branch on, the true/false values to
+  // select between, and a branch opcode to use.
+  const BasicBlock *LLVM_BB = BB->getBasicBlock();
+  MachineFunction::iterator I = BB;
+  ++I;
+
+  //  thisMBB:
+  //  ...
+  //   TrueVal = ...
+  //   jmp_XX r1, r2 goto copy1MBB
+  //   fallthrough --> copy0MBB
+  MachineBasicBlock *thisMBB = BB;
+  MachineFunction *F = BB->getParent();
+  MachineBasicBlock *copy0MBB = F->CreateMachineBasicBlock(LLVM_BB);
+  MachineBasicBlock *copy1MBB = F->CreateMachineBasicBlock(LLVM_BB);
+
+  F->insert(I, copy0MBB);
+  F->insert(I, copy1MBB);
+  // Update machine-CFG edges by transferring all successors of the current
+  // block to the new block which will contain the Phi node for the select.
+  copy1MBB->splice(copy1MBB->begin(), BB,
+                   llvm::next(MachineBasicBlock::iterator(MI)),
+                   BB->end());
+  copy1MBB->transferSuccessorsAndUpdatePHIs(BB);
+  // Next, add the true and fallthrough blocks as its successors.
+  BB->addSuccessor(copy0MBB);
+  BB->addSuccessor(copy1MBB);
+
+  // Insert Branch if Flag
+  unsigned LHS = MI->getOperand(1).getReg();
+  unsigned RHS = MI->getOperand(2).getReg();
+  int CC  = MI->getOperand(3).getImm();
+  switch (CC) {
+  case ISD::SETGT:
+    BuildMI(BB, dl, TII.get(BPF::JSGT_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  case ISD::SETUGT:
+    BuildMI(BB, dl, TII.get(BPF::JUGT_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  case ISD::SETGE:
+    BuildMI(BB, dl, TII.get(BPF::JSGE_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  case ISD::SETUGE:
+    BuildMI(BB, dl, TII.get(BPF::JUGE_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  case ISD::SETEQ:
+    BuildMI(BB, dl, TII.get(BPF::JEQ_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  case ISD::SETNE:
+    BuildMI(BB, dl, TII.get(BPF::JNE_rr))
+      .addReg(LHS).addReg(RHS).addMBB(copy1MBB);
+    break;
+  default:
+    report_fatal_error("unimplemented select CondCode " + Twine(CC));
+  }
+
+  //  copy0MBB:
+  //   %FalseValue = ...
+  //   # fallthrough to copy1MBB
+  BB = copy0MBB;
+
+  // Update machine-CFG edges
+  BB->addSuccessor(copy1MBB);
+
+  //  copy1MBB:
+  //   %Result = phi [ %FalseValue, copy0MBB ], [ %TrueValue, thisMBB ]
+  //  ...
+  BB = copy1MBB;
+  BuildMI(*BB, BB->begin(), dl, TII.get(BPF::PHI),
+          MI->getOperand(0).getReg())
+    .addReg(MI->getOperand(5).getReg()).addMBB(copy0MBB)
+    .addReg(MI->getOperand(4).getReg()).addMBB(thisMBB);
+
+  MI->eraseFromParent();   // The pseudo instruction is gone now.
+  return BB;
+}
+
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h b/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h
new file mode 100644
index 0000000..0850a9e
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h
@@ -0,0 +1,105 @@
+//===-- BPFISelLowering.h - BPF DAG Lowering Interface -......-*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file defines the interfaces that BPF uses to lower LLVM code into a
+// selection DAG.
+
+#ifndef LLVM_TARGET_BPF_ISELLOWERING_H
+#define LLVM_TARGET_BPF_ISELLOWERING_H
+
+#include "BPF.h"
+#include "llvm/CodeGen/SelectionDAG.h"
+#include "llvm/Target/TargetLowering.h"
+
+namespace llvm {
+  namespace BPFISD {
+    enum {
+      FIRST_NUMBER = ISD::BUILTIN_OP_END,
+
+      ADJDYNALLOC,
+
+      /// Return with a flag operand. Operand 0 is the chain operand.
+      RET_FLAG,
+
+      /// CALL - These operations represent an abstract call instruction, which
+      /// includes a bunch of information.
+      CALL,
+
+      /// SELECT_CC - Operand 0 and operand 1 are selection variable, operand 3
+      /// is condition code and operand 4 is flag operand.
+      SELECT_CC,
+
+      // BR_CC - Used to glue together a l.bf to a l.sfXX
+      BR_CC,
+
+      /// Wrapper - A wrapper node for TargetConstantPool, TargetExternalSymbol,
+      /// and TargetGlobalAddress.
+      Wrapper
+    };
+  }
+
+  class BPFSubtarget;
+  class BPFTargetMachine;
+
+  class BPFTargetLowering : public TargetLowering {
+  public:
+    explicit BPFTargetLowering(BPFTargetMachine &TM);
+
+    /// LowerOperation - Provide custom lowering hooks for some operations.
+    virtual SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const;
+
+    /// getTargetNodeName - This method returns the name of a target specific
+    /// DAG node.
+    virtual const char *getTargetNodeName(unsigned Opcode) const;
+
+    SDValue LowerBR_CC(SDValue Op, SelectionDAG &DAG) const;
+    SDValue LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
+    SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
+
+    MachineBasicBlock* EmitInstrWithCustomInserter(MachineInstr *MI,
+                                                   MachineBasicBlock *BB) const;
+
+  private:
+    const BPFSubtarget &Subtarget;
+    const BPFTargetMachine &TM;
+
+    SDValue LowerCallResult(SDValue Chain, SDValue InFlag,
+                            CallingConv::ID CallConv, bool isVarArg,
+                            const SmallVectorImpl<ISD::InputArg> &Ins,
+#if LLVM_VERSION_MINOR==4
+                            SDLoc dl,
+#else
+                            DebugLoc dl,
+#endif
+                            SelectionDAG &DAG,
+                            SmallVectorImpl<SDValue> &InVals) const;
+
+    SDValue LowerCall(TargetLowering::CallLoweringInfo &CLI,
+                      SmallVectorImpl<SDValue> &InVals) const;
+
+    SDValue LowerFormalArguments(SDValue Chain,
+                                 CallingConv::ID CallConv, bool isVarArg,
+                                 const SmallVectorImpl<ISD::InputArg> &Ins,
+#if LLVM_VERSION_MINOR==4
+                                 SDLoc dl,
+#else
+                                 DebugLoc dl,
+#endif
+                                 SelectionDAG &DAG,
+                                 SmallVectorImpl<SDValue> &InVals) const;
+
+    SDValue LowerReturn(SDValue Chain,
+                        CallingConv::ID CallConv, bool isVarArg,
+                        const SmallVectorImpl<ISD::OutputArg> &Outs,
+                        const SmallVectorImpl<SDValue> &OutVals,
+#if LLVM_VERSION_MINOR==4
+                        SDLoc dl,
+#else
+                        DebugLoc dl,
+#endif
+                        SelectionDAG &DAG) const;
+  };
+}
+
+#endif // LLVM_TARGET_BPF_ISELLOWERING_H
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td b/tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td
new file mode 100644
index 0000000..122ff19
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td
@@ -0,0 +1,29 @@
+//===- BPFInstrFormats.td - BPF Instruction Formats ----*- tablegen -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+class InstBPF<dag outs, dag ins, string asmstr, list<dag> pattern>
+  : Instruction {
+  field bits<64> Inst;
+  field bits<64> SoftFail = 0;
+  let Size = 8;
+
+  let Namespace = "BPF";
+  let DecoderNamespace = "BPF";
+
+  bits<3> bpfClass;
+  let Inst{58-56} = bpfClass;
+
+  dag OutOperandList = outs;
+  dag InOperandList = ins;
+  let AsmString = asmstr;
+  let Pattern = pattern;
+}
+
+// Pseudo instructions
+class Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>
+  : InstBPF<outs, ins, asmstr, pattern> {
+  let Inst{63-0} = 0;
+  let isPseudo = 1;
+}
+
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp
new file mode 100644
index 0000000..943de85
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp
@@ -0,0 +1,162 @@
+//===-- BPFInstrInfo.cpp - BPF Instruction Information --------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains the BPF implementation of the TargetInstrInfo class.
+
+#include "BPF.h"
+#include "BPFInstrInfo.h"
+#include "BPFSubtarget.h"
+#include "BPFTargetMachine.h"
+#include "llvm/CodeGen/MachineFunctionPass.h"
+#include "llvm/CodeGen/MachineInstrBuilder.h"
+#include "llvm/CodeGen/MachineRegisterInfo.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/TargetRegistry.h"
+#include "llvm/ADT/STLExtras.h"
+#include "llvm/ADT/SmallVector.h"
+
+#define GET_INSTRINFO_CTOR_DTOR /* for 3.4 */
+#define GET_INSTRINFO_CTOR /* for 3.2, 3.3 */
+#include "BPFGenInstrInfo.inc"
+
+using namespace llvm;
+
+BPFInstrInfo::BPFInstrInfo()
+  : BPFGenInstrInfo(BPF::ADJCALLSTACKDOWN, BPF::ADJCALLSTACKUP),
+    RI(*this) {
+}
+
+void BPFInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
+                                MachineBasicBlock::iterator I, DebugLoc DL,
+                                unsigned DestReg, unsigned SrcReg,
+                                bool KillSrc) const {
+  if (BPF::GPRRegClass.contains(DestReg, SrcReg))
+    BuildMI(MBB, I, DL, get(BPF::MOV_rr), DestReg)
+      .addReg(SrcReg, getKillRegState(KillSrc));
+  else
+    llvm_unreachable("Impossible reg-to-reg copy");
+}
+
+void BPFInstrInfo::
+storeRegToStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
+                    unsigned SrcReg, bool isKill, int FI,
+                    const TargetRegisterClass *RC,
+                    const TargetRegisterInfo *TRI) const {
+  DebugLoc DL;
+  if (I != MBB.end()) DL = I->getDebugLoc();
+
+  if (RC == &BPF::GPRRegClass)
+    BuildMI(MBB, I, DL, get(BPF::STD)).addReg(SrcReg, getKillRegState(isKill))
+      .addFrameIndex(FI).addImm(0);
+  else
+    llvm_unreachable("Can't store this register to stack slot");
+}
+
+void BPFInstrInfo::
+loadRegFromStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
+                     unsigned DestReg, int FI,
+                     const TargetRegisterClass *RC,
+                     const TargetRegisterInfo *TRI) const {
+  DebugLoc DL;
+  if (I != MBB.end()) DL = I->getDebugLoc();
+
+  if (RC == &BPF::GPRRegClass)
+    BuildMI(MBB, I, DL, get(BPF::LDD), DestReg).addFrameIndex(FI).addImm(0);
+  else
+    llvm_unreachable("Can't load this register from stack slot");
+}
+
+bool BPFInstrInfo::AnalyzeBranch(MachineBasicBlock &MBB,
+                                  MachineBasicBlock *&TBB,
+                                  MachineBasicBlock *&FBB,
+                                  SmallVectorImpl<MachineOperand> &Cond,
+                                  bool AllowModify) const {
+  // Start from the bottom of the block and work up, examining the
+  // terminator instructions.
+  MachineBasicBlock::iterator I = MBB.end();
+  while (I != MBB.begin()) {
+    --I;
+    if (I->isDebugValue())
+      continue;
+
+    // Working from the bottom, when we see a non-terminator
+    // instruction, we're done.
+    if (!isUnpredicatedTerminator(I))
+      break;
+
+    // A terminator that isn't a branch can't easily be handled
+    // by this analysis.
+    if (!I->isBranch())
+      return true;
+
+    // Handle unconditional branches.
+    if (I->getOpcode() == BPF::JMP) {
+      if (!AllowModify) {
+        TBB = I->getOperand(0).getMBB();
+        continue;
+      }
+
+      // If the block has any instructions after a J, delete them.
+      while (llvm::next(I) != MBB.end())
+        llvm::next(I)->eraseFromParent();
+      Cond.clear();
+      FBB = 0;
+
+      // Delete the J if it's equivalent to a fall-through.
+      if (MBB.isLayoutSuccessor(I->getOperand(0).getMBB())) {
+        TBB = 0;
+        I->eraseFromParent();
+        I = MBB.end();
+        continue;
+      }
+
+      // TBB is used to indicate the unconditinal destination.
+      TBB = I->getOperand(0).getMBB();
+      continue;
+    }
+    // Cannot handle conditional branches
+    return true;
+  }
+
+  return false;
+}
+
+unsigned
+BPFInstrInfo::InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
+                            MachineBasicBlock *FBB,
+                            const SmallVectorImpl<MachineOperand> &Cond,
+                            DebugLoc DL) const {
+  // Shouldn't be a fall through.
+  assert(TBB && "InsertBranch must not be told to insert a fallthrough");
+
+  if (Cond.empty()) {
+    // Unconditional branch
+    assert(!FBB && "Unconditional branch with multiple successors!");
+    BuildMI(&MBB, DL, get(BPF::JMP)).addMBB(TBB);
+    return 1;
+  }
+
+  llvm_unreachable("Unexpected conditional branch");
+  return 0;
+}
+
+unsigned BPFInstrInfo::RemoveBranch(MachineBasicBlock &MBB) const {
+  MachineBasicBlock::iterator I = MBB.end();
+  unsigned Count = 0;
+
+  while (I != MBB.begin()) {
+    --I;
+    if (I->isDebugValue())
+      continue;
+    if (I->getOpcode() != BPF::JMP)
+      break;
+    // Remove the branch.
+    I->eraseFromParent();
+    I = MBB.end();
+    ++Count;
+  }
+
+  return Count;
+}
+
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h
new file mode 100644
index 0000000..911387d
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h
@@ -0,0 +1,53 @@
+//===- BPFInstrInfo.h - BPF Instruction Information ---------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef BPFINSTRUCTIONINFO_H
+#define BPFINSTRUCTIONINFO_H
+
+#include "BPFRegisterInfo.h"
+#include "BPFSubtarget.h"
+#include "llvm/Target/TargetInstrInfo.h"
+
+#define GET_INSTRINFO_HEADER
+#include "BPFGenInstrInfo.inc"
+
+namespace llvm {
+
+class BPFInstrInfo : public BPFGenInstrInfo {
+  const BPFRegisterInfo RI;
+public:
+  BPFInstrInfo();
+
+  virtual const BPFRegisterInfo &getRegisterInfo() const { return RI; }
+
+  virtual void copyPhysReg(MachineBasicBlock &MBB,
+                           MachineBasicBlock::iterator I, DebugLoc DL,
+                           unsigned DestReg, unsigned SrcReg,
+                           bool KillSrc) const;
+
+  virtual void storeRegToStackSlot(MachineBasicBlock &MBB,
+                                   MachineBasicBlock::iterator MBBI,
+                                   unsigned SrcReg, bool isKill, int FrameIndex,
+                                   const TargetRegisterClass *RC,
+                                   const TargetRegisterInfo *TRI) const;
+
+  virtual void loadRegFromStackSlot(MachineBasicBlock &MBB,
+                                    MachineBasicBlock::iterator MBBI,
+                                    unsigned DestReg, int FrameIndex,
+                                    const TargetRegisterClass *RC,
+                                    const TargetRegisterInfo *TRI) const;
+  bool AnalyzeBranch(MachineBasicBlock &MBB,
+                     MachineBasicBlock *&TBB, MachineBasicBlock *&FBB,
+                     SmallVectorImpl<MachineOperand> &Cond,
+                     bool AllowModify) const;
+
+  unsigned RemoveBranch(MachineBasicBlock &MBB) const;
+  unsigned InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
+                        MachineBasicBlock *FBB,
+                        const SmallVectorImpl<MachineOperand> &Cond,
+                        DebugLoc DL) const;
+};
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td
new file mode 100644
index 0000000..ca95d9c
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td
@@ -0,0 +1,455 @@
+//===-- BPFInstrInfo.td - Target Description for BPF Target -------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file describes the BPF instructions in TableGen format.
+
+include "BPFInstrFormats.td"
+
+// Instruction Operands and Patterns
+
+//  These are target-independent nodes, but have target-specific formats.
+def SDT_BPFCallSeqStart : SDCallSeqStart<[ SDTCisVT<0, iPTR> ]>;
+def SDT_BPFCallSeqEnd   : SDCallSeqEnd<[ SDTCisVT<0, iPTR>,
+                                          SDTCisVT<1, iPTR> ]>;
+def SDT_BPFCall         : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;
+def SDT_BPFSetFlag      : SDTypeProfile<0, 3, [SDTCisSameAs<0, 1>]>;
+def SDT_BPFSelectCC     : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>, SDTCisSameAs<0, 4>,
+                                                SDTCisSameAs<4, 5>]>;
+def SDT_BPFBrCC         : SDTypeProfile<0, 4, [SDTCisSameAs<0, 1>, SDTCisVT<3, OtherVT>]>;
+
+def SDT_BPFWrapper      : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>,
+                                                SDTCisPtrTy<0>]>;
+//def SDT_BPFAdjDynAlloc  : SDTypeProfile<1, 1, [SDTCisVT<0, i64>,
+//                                                SDTCisVT<1, i64>]>;
+
+def call            : SDNode<"BPFISD::CALL", SDT_BPFCall,
+                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
+                              SDNPVariadic]>;
+def retflag         : SDNode<"BPFISD::RET_FLAG", SDTNone,
+                             [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
+def callseq_start   : SDNode<"ISD::CALLSEQ_START", SDT_BPFCallSeqStart,
+                             [SDNPHasChain, SDNPOutGlue]>;
+def callseq_end     : SDNode<"ISD::CALLSEQ_END",   SDT_BPFCallSeqEnd,
+                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
+def BPFbrcc        : SDNode<"BPFISD::BR_CC", SDT_BPFBrCC,
+                              [SDNPHasChain, SDNPOutGlue, SDNPInGlue]>;
+
+def BPFselectcc    : SDNode<"BPFISD::SELECT_CC", SDT_BPFSelectCC, [SDNPInGlue]>;
+def BPFWrapper     : SDNode<"BPFISD::Wrapper", SDT_BPFWrapper>;
+
+//def BPFadjdynalloc : SDNode<"BPFISD::ADJDYNALLOC", SDT_BPFAdjDynAlloc>;
+
+// helper macros to produce 64-bit constant
+// 0x11223344 55667788 ->
+// reg = 0x11223344
+// reg <<= 32
+// reg += 0x55667788
+//
+// 0x11223344 FF667788 ->
+// reg = 0x11223345
+// reg <<= 32
+// reg += (long long)(int)0xFF667788
+def LO32 : SDNodeXForm<imm, [{
+  return CurDAG->getTargetConstant((int64_t)(int32_t)(uint64_t)N->getZExtValue(),
+                                   MVT::i64);
+}]>;
+def HI32 : SDNodeXForm<imm, [{
+  return CurDAG->getTargetConstant(((int64_t)N->getZExtValue() -
+         (int64_t)(int32_t)(uint64_t)N->getZExtValue()) >> 32, MVT::i64);
+}]>;
+
+
+def brtarget : Operand<OtherVT>;
+def calltarget : Operand<i64>;
+
+def s32imm   : Operand<i64> {
+  let PrintMethod = "printS32ImmOperand";
+}
+
+def immSExt32 : PatLeaf<(imm),
+                [{return isInt<32>(N->getSExtValue()); }]>;
+
+// Addressing modes.
+def ADDRri : ComplexPattern<i64, 2, "SelectAddr", [frameindex], []>;
+
+// Address operands
+def MEMri : Operand<i64> {
+  let PrintMethod = "printMemOperand";
+  let EncoderMethod = "getMemoryOpValue";
+  let DecoderMethod = "todo_decode_memri";
+  let MIOperandInfo = (ops GPR, i16imm);
+}
+
+// Conditional code predicates - used for pattern matching for SF instructions
+def BPF_CC_EQ  : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETEQ);}]>;
+def BPF_CC_NE  : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETNE);}]>;
+def BPF_CC_GE  : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETGE);}]>;
+def BPF_CC_GT  : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETGT);}]>;
+def BPF_CC_GTU : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETUGT);}]>;
+def BPF_CC_GEU : PatLeaf<(imm),
+                  [{return (N->getZExtValue() == ISD::SETUGE);}]>;
+
+// jump instructions
+class JMP_RR<bits<4> br_op, string asmstr, PatLeaf Cond>
+  : InstBPF<(outs), (ins GPR:$rA, GPR:$rX, brtarget:$dst),
+           !strconcat(asmstr, "\t$rA, $rX goto $dst"),
+           [(BPFbrcc (i64 GPR:$rA), (i64 GPR:$rX), Cond, bb:$dst)]> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<4> rX;
+  bits<16> dst;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{55-52} = rX;
+  let Inst{51-48} = rA;
+  let Inst{47-32} = dst;
+
+  let op = br_op;
+  let src = 1;
+  let bpfClass = 5; // BPF_JUMP
+}
+
+class JMP_RI<bits<4> br_op, string asmstr, PatLeaf Cond>
+  : InstBPF<(outs), (ins GPR:$rA, s32imm:$imm, brtarget:$dst),
+           !strconcat(asmstr, "i\t$rA, $imm goto $dst"),
+           [(BPFbrcc (i64 GPR:$rA), immSExt32:$imm, Cond, bb:$dst)]> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<16> dst;
+  bits<32> imm;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{51-48} = rA;
+  let Inst{47-32} = dst;
+  let Inst{31-0} = imm;
+
+  let op = br_op;
+  let src = 0;
+  let bpfClass = 5; // BPF_JUMP
+}
+
+multiclass J<bits<4> op2Val, string asmstr, PatLeaf Cond> {
+  def _rr : JMP_RR<op2Val, asmstr, Cond>;
+  def _ri : JMP_RI<op2Val, asmstr, Cond>;
+}
+
+let isBranch = 1, isTerminator = 1, hasDelaySlot=0 in {
+// cmp+goto instructions
+defm JEQ  : J<0x1, "jeq",  BPF_CC_EQ>;
+defm JUGT : J<0x2, "jgt", BPF_CC_GTU>;
+defm JUGE : J<0x3, "jge", BPF_CC_GEU>;
+defm JNE  : J<0x5, "jne",  BPF_CC_NE>;
+defm JSGT : J<0x6, "jsgt", BPF_CC_GT>;
+defm JSGE : J<0x7, "jsge", BPF_CC_GE>;
+}
+
+// ALU instructions
+class ALU_RI<bits<4> aluOp, string asmstr, SDNode OpNode>
+  : InstBPF<(outs GPR:$rA), (ins GPR:$rS, s32imm:$imm),
+            !strconcat(asmstr, "i\t$rA, $imm"),
+            [(set GPR:$rA, (OpNode GPR:$rS, immSExt32:$imm))]> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<32> imm;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{51-48} = rA;
+  let Inst{31-0} = imm;
+
+  let op = aluOp;
+  let src = 0;
+  let bpfClass = 4;
+}
+
+class ALU_RR<bits<4> aluOp, string asmstr, SDNode OpNode>
+  : InstBPF<(outs GPR:$rA), (ins GPR:$rS, GPR:$rX),
+            !strconcat(asmstr, "\t$rA, $rX"),
+            [(set GPR:$rA, (OpNode (i64 GPR:$rS), (i64 GPR:$rX)))]> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<4> rX;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{55-52} = rX;
+  let Inst{51-48} = rA;
+
+  let op = aluOp;
+  let src = 1;
+  let bpfClass = 4;
+}
+
+multiclass ALU<bits<4> opVal, string asmstr, SDNode OpNode> {
+  def _rr : ALU_RR<opVal, asmstr, OpNode>;
+  def _ri : ALU_RI<opVal, asmstr, OpNode>;
+}
+
+let Constraints = "$rA = $rS" in {
+let isAsCheapAsAMove = 1 in {
+  defm ADD : ALU<0x0, "add", add>;
+  defm SUB : ALU<0x1, "sub", sub>;
+  defm OR  : ALU<0x4, "or", or>;
+  defm AND : ALU<0x5, "and", and>;
+  defm SLL : ALU<0x6, "sll", shl>;
+  defm SRL : ALU<0x7, "srl", srl>;
+  defm XOR : ALU<0xa, "xor", xor>;
+  defm SRA : ALU<0xc, "sra", sra>;
+}
+  defm MUL : ALU<0x2, "mul", mul>;
+  defm DIV : ALU<0x3, "div", udiv>;
+}
+
+class MOV_RR<string asmstr>
+  : InstBPF<(outs GPR:$rA), (ins GPR:$rX),
+            !strconcat(asmstr, "\t$rA, $rX"),
+            []> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<4> rX;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{55-52} = rX;
+  let Inst{51-48} = rA;
+
+  let op = 0xb;
+  let src = 1;
+  let bpfClass = 4;
+}
+
+class MOV_RI<string asmstr>
+  : InstBPF<(outs GPR:$rA), (ins s32imm:$imm),
+            !strconcat(asmstr, "\t$rA, $imm"),
+            [(set GPR:$rA, (i64 immSExt32:$imm))]> {
+  bits<4> op;
+  bits<1> src;
+  bits<4> rA;
+  bits<32> imm;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{51-48} = rA;
+  let Inst{31-0} = imm;
+
+  let op = 0xb;
+  let src = 0;
+  let bpfClass = 4;
+}
+def MOV_rr : MOV_RR<"mov">;
+def MOV_ri : MOV_RI<"mov">;
+
+// STORE instructions
+class STORE<bits<2> sizeOp, string asmstring, list<dag> pattern>
+  : InstBPF<(outs), (ins GPR:$rX, MEMri:$addr),
+          !strconcat(asmstring, "\t$addr, $rX"), pattern> {
+  bits<3> mode;
+  bits<2> size;
+  bits<4> rX;
+  bits<20> addr;
+
+  let Inst{63-61} = mode;
+  let Inst{60-59} = size;
+  let Inst{51-48} = addr{19-16}; // base reg
+  let Inst{55-52} = rX;
+  let Inst{47-32} = addr{15-0}; // offset
+
+  let mode = 6; // BPF_REL
+  let size = sizeOp;
+  let bpfClass = 3; // BPF_STX
+}
+
+class STOREi64<bits<2> subOp, string asmstring, PatFrag opNode>
+  : STORE<subOp, asmstring, [(opNode (i64 GPR:$rX), ADDRri:$addr)]>;
+
+def STW : STOREi64<0x0, "stw", truncstorei32>;
+def STH : STOREi64<0x1, "sth", truncstorei16>;
+def STB : STOREi64<0x2, "stb", truncstorei8>;
+def STD : STOREi64<0x3, "std", store>;
+
+// LOAD instructions
+class LOAD<bits<2> sizeOp, string asmstring, list<dag> pattern>
+  : InstBPF<(outs GPR:$rA), (ins MEMri:$addr),
+           !strconcat(asmstring, "\t$rA, $addr"), pattern> {
+  bits<3> mode;
+  bits<2> size;
+  bits<4> rA;
+  bits<20> addr;
+
+  let Inst{63-61} = mode;
+  let Inst{60-59} = size;
+  let Inst{51-48} = rA;
+  let Inst{55-52} = addr{19-16};
+  let Inst{47-32} = addr{15-0};
+
+  let mode = 6; // BPF_REL
+  let size = sizeOp;
+  let bpfClass = 1; // BPF_LDX
+}
+
+class LOADi64<bits<2> sizeOp, string asmstring, PatFrag opNode>
+  : LOAD<sizeOp, asmstring, [(set (i64 GPR:$rA), (opNode ADDRri:$addr))]>;
+
+def LDW : LOADi64<0x0, "ldw", zextloadi32>;
+def LDH : LOADi64<0x1, "ldh", zextloadi16>;
+def LDB : LOADi64<0x2, "ldb", zextloadi8>;
+def LDD : LOADi64<0x3, "ldd", load>;
+
+//def LDBS : LOADi64<0x2, "ldbs", sextloadi8>;
+//def LDHS : LOADi64<0x1, "ldhs", sextloadi16>;
+//def LDWS : LOADi64<0x0, "ldws", sextloadi32>;
+
+class BRANCH<bits<4> subOp, string asmstring, list<dag> pattern>
+  : InstBPF<(outs), (ins brtarget:$dst),
+           !strconcat(asmstring, "\t$dst"), pattern> {
+  bits<4> op;
+  bits<16> dst;
+  bits<1> src;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{47-32} = dst;
+
+  let op = subOp;
+  let src = 1;
+  let bpfClass = 5; // BPF_JUMP
+}
+
+class CALL<string asmstring>
+  : InstBPF<(outs), (ins calltarget:$dst),
+           !strconcat(asmstring, "\t$dst"), []> {
+  bits<4> op;
+  bits<32> dst;
+  bits<1> src;
+
+  let Inst{63-60} = op;
+  let Inst{59} = src;
+  let Inst{31-0} = dst;
+
+  let op = 8; // BPF_CALL
+  let src = 0;
+  let bpfClass = 5; // BPF_JUMP
+}
+
+// Jump always
+let isBranch = 1, isTerminator = 1, hasDelaySlot=0, isBarrier = 1 in {
+  def JMP : BRANCH<0x0, "jmp", [(br bb:$dst)]>;
+}
+
+// Jump and link
+let isCall=1, hasDelaySlot=0,
+    Uses = [R11],
+    // Potentially clobbered registers
+    Defs = [R0, R1, R2, R3, R4, R5] in {
+  def JAL  : CALL<"call">;
+}
+
+class NOP_I<string asmstr>
+  : InstBPF<(outs), (ins i32imm:$imm),
+           !strconcat(asmstr, "\t$imm"), []> {
+  bits<32> imm;
+
+  let Inst{31-0} = imm;
+
+  let Inst{63-59} = 0;
+  let bpfClass = 7; // BPF_MISC
+}
+
+let neverHasSideEffects = 1 in
+  def NOP : NOP_I<"nop">;
+
+class RET<string asmstring>
+  : InstBPF<(outs), (ins),
+           !strconcat(asmstring, ""), [(retflag)]> {
+  let Inst{63-59} = 0;
+  let bpfClass = 6; // BPF_RET
+}
+
+let isReturn = 1, isTerminator = 1, hasDelaySlot=0, isBarrier = 1, isNotDuplicable = 1 in {
+  def RET : RET<"ret">;
+}
+
+// ADJCALLSTACKDOWN/UP pseudo insns
+let Defs = [R11], Uses = [R11] in {
+def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i64imm:$amt),
+                              "#ADJCALLSTACKDOWN $amt",
+                              [(callseq_start timm:$amt)]>;
+def ADJCALLSTACKUP   : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
+                              "#ADJCALLSTACKUP $amt1 $amt2",
+                              [(callseq_end timm:$amt1, timm:$amt2)]>;
+}
+
+
+//let Defs = [R11], Uses = [R11] in {
+//  def ADJDYNALLOC : Pseudo<(outs GPR:$dst), (ins GPR:$src),
+//                    "#ADJDYNALLOC $dst $src",
+//                    [(set GPR:$dst, (BPFadjdynalloc GPR:$src))]>;
+//}
+
+
+let usesCustomInserter = 1 in {
+  def Select : Pseudo<(outs GPR:$dst), (ins GPR:$lhs, GPR:$rhs, s32imm:$imm, GPR:$src, GPR:$src2),
+                       "# Select PSEUDO $dst = $lhs $imm $rhs ? $src : $src2",
+                       [(set (i64 GPR:$dst),
+                        (BPFselectcc (i64 GPR:$lhs), (i64 GPR:$rhs), (i64 imm:$imm), (i64 GPR:$src), (i64 GPR:$src2)))]>;
+}
+
+// Non-Instruction Patterns
+
+// arbitrary immediate
+def : Pat<(i64 imm:$imm), (ADD_ri (SLL_ri (MOV_ri (HI32 imm:$imm)), 32), (LO32 imm:$imm))>;
+
+// 0xffffFFFF doesn't fit into simm32, optimize common case
+def : Pat<(i64 (and (i64 GPR:$src), 0xffffFFFF)), (SRL_ri (SLL_ri (i64 GPR:$src), 32), 32)>;
+
+// Calls
+def : Pat<(call tglobaladdr:$dst), (JAL tglobaladdr:$dst)>;
+//def : Pat<(call texternalsym:$dst), (JAL texternalsym:$dst)>;
+//def : Pat<(call (i32 imm:$dst)), (JAL (i32 imm:$dst))>;
+//def : Pat<(call imm:$dst), (JAL imm:$dst)>;
+
+// Loads
+def : Pat<(extloadi8  ADDRri:$src), (i64 (LDB ADDRri:$src))>;
+def : Pat<(extloadi16 ADDRri:$src), (i64 (LDH ADDRri:$src))>;
+def : Pat<(extloadi32 ADDRri:$src), (i64 (LDW ADDRri:$src))>;
+
+// Atomics
+class XADD<bits<2> sizeOp, string asmstr, PatFrag opNode>
+  : InstBPF<(outs GPR:$dst), (ins MEMri:$addr, GPR:$val),
+            !strconcat(asmstr, "\t$dst, $addr, $val"),
+            [(set GPR:$dst, (opNode ADDRri:$addr, GPR:$val))]> {
+  bits<3> mode;
+  bits<2> size;
+  bits<4> rX;
+  bits<20> addr;
+
+  let Inst{63-61} = mode;
+  let Inst{60-59} = size;
+  let Inst{51-48} = addr{19-16}; // base reg
+  let Inst{55-52} = rX;
+  let Inst{47-32} = addr{15-0}; // offset
+
+  let mode = 7; // BPF_XADD
+  let size = sizeOp;
+  let bpfClass = 3; // BPF_STX
+}
+
+let Constraints = "$dst = $val" in {
+def XADD32 : XADD<0, "xadd32", atomic_load_add_32>;
+def XADD16 : XADD<1, "xadd16", atomic_load_add_16>;
+def XADD8  : XADD<2, "xadd8", atomic_load_add_8>;
+def XADD64 : XADD<3, "xadd64", atomic_load_add_64>;
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp
new file mode 100644
index 0000000..5c15ed7
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp
@@ -0,0 +1,77 @@
+//=-- BPFMCInstLower.cpp - Convert BPF MachineInstr to an MCInst ----------=//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains code to lower BPF MachineInstrs to their corresponding
+// MCInst records.
+
+#include "BPFMCInstLower.h"
+#include "MCTargetDesc/BPFBaseInfo.h"
+#include "llvm/CodeGen/AsmPrinter.h"
+#include "llvm/CodeGen/MachineBasicBlock.h"
+#include "llvm/CodeGen/MachineInstr.h"
+#include "llvm/MC/MCAsmInfo.h"
+#include "llvm/MC/MCContext.h"
+#include "llvm/MC/MCExpr.h"
+#include "llvm/MC/MCInst.h"
+#include "llvm/Target/Mangler.h"
+#include "llvm/Support/raw_ostream.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/ADT/SmallString.h"
+using namespace llvm;
+
+MCSymbol *BPFMCInstLower::
+GetGlobalAddressSymbol(const MachineOperand &MO) const {
+#if LLVM_VERSION_MINOR==4
+  return Printer.getSymbol(MO.getGlobal());
+#else
+  return Printer.Mang->getSymbol(MO.getGlobal());
+#endif
+}
+
+MCOperand BPFMCInstLower::
+LowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym) const {
+
+  const MCExpr *Expr = MCSymbolRefExpr::Create(Sym, Ctx);
+
+  if (!MO.isJTI() && MO.getOffset())
+    llvm_unreachable("unknown symbol op");
+//    Expr = MCBinaryExpr::CreateAdd(Expr,
+//                                   MCConstantExpr::Create(MO.getOffset(), Ctx),
+//                                   Ctx);
+  return MCOperand::CreateExpr(Expr);
+}
+
+void BPFMCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
+  OutMI.setOpcode(MI->getOpcode());
+
+  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
+    const MachineOperand &MO = MI->getOperand(i);
+
+    MCOperand MCOp;
+    switch (MO.getType()) {
+    default:
+      MI->dump();
+      llvm_unreachable("unknown operand type");
+    case MachineOperand::MO_Register:
+      // Ignore all implicit register operands.
+      if (MO.isImplicit()) continue;
+      MCOp = MCOperand::CreateReg(MO.getReg());
+      break;
+    case MachineOperand::MO_Immediate:
+      MCOp = MCOperand::CreateImm(MO.getImm());
+      break;
+    case MachineOperand::MO_MachineBasicBlock:
+      MCOp = MCOperand::CreateExpr(MCSymbolRefExpr::Create(
+                                   MO.getMBB()->getSymbol(), Ctx));
+      break;
+    case MachineOperand::MO_RegisterMask:
+      continue;
+    case MachineOperand::MO_GlobalAddress:
+      MCOp = LowerSymbolOperand(MO, GetGlobalAddressSymbol(MO));
+      break;
+    }
+
+    OutMI.addOperand(MCOp);
+  }
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h b/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h
new file mode 100644
index 0000000..aaff0c3
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h
@@ -0,0 +1,40 @@
+//===-- BPFMCInstLower.h - Lower MachineInstr to MCInst --------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef BPF_MCINSTLOWER_H
+#define BPF_MCINSTLOWER_H
+
+#include "llvm/Support/Compiler.h"
+
+namespace llvm {
+  class AsmPrinter;
+  class MCContext;
+  class MCInst;
+  class MCOperand;
+  class MCSymbol;
+  class MachineInstr;
+  class MachineModuleInfoMachO;
+  class MachineOperand;
+  class Mangler;
+
+  /// BPFMCInstLower - This class is used to lower an MachineInstr
+  /// into an MCInst.
+class LLVM_LIBRARY_VISIBILITY BPFMCInstLower {
+  MCContext &Ctx;
+  Mangler &Mang;
+
+  AsmPrinter &Printer;
+public:
+  BPFMCInstLower(MCContext &ctx, Mangler &mang, AsmPrinter &printer)
+    : Ctx(ctx), Mang(mang), Printer(printer) {}
+  void Lower(const MachineInstr *MI, MCInst &OutMI) const;
+
+  MCOperand LowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym) const;
+
+  MCSymbol *GetGlobalAddressSymbol(const MachineOperand &MO) const;
+};
+
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp
new file mode 100644
index 0000000..7d46041
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp
@@ -0,0 +1,122 @@
+//===-- BPFRegisterInfo.cpp - BPF Register Information --------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains the BPF implementation of the TargetRegisterInfo class.
+
+#include "BPF.h"
+#include "BPFRegisterInfo.h"
+#include "BPFSubtarget.h"
+#include "llvm/CodeGen/MachineInstrBuilder.h"
+#include "llvm/CodeGen/MachineFrameInfo.h"
+#include "llvm/CodeGen/MachineFunction.h"
+#include "llvm/CodeGen/RegisterScavenging.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Target/TargetFrameLowering.h"
+#include "llvm/Target/TargetInstrInfo.h"
+
+#define GET_REGINFO_TARGET_DESC
+#include "BPFGenRegisterInfo.inc"
+using namespace llvm;
+
+BPFRegisterInfo::BPFRegisterInfo(const TargetInstrInfo &tii)
+  : BPFGenRegisterInfo(BPF::R0), TII(tii) {
+}
+
+const uint16_t*
+BPFRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
+  return CSR_SaveList;
+}
+
+BitVector BPFRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
+  BitVector Reserved(getNumRegs());
+  Reserved.set(BPF::R10);
+  Reserved.set(BPF::R11);
+  return Reserved;
+}
+
+bool
+BPFRegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
+  return true;
+}
+
+void
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+BPFRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
+                           int SPAdj, unsigned FIOperandNum,
+                           RegScavenger *RS) const {
+#else
+BPFRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
+                                       int SPAdj, RegScavenger *RS) const {
+#endif
+  assert(SPAdj == 0 && "Unexpected");
+
+  unsigned i = 0;
+  MachineInstr &MI = *II;
+  MachineFunction &MF = *MI.getParent()->getParent();
+  DebugLoc dl = MI.getDebugLoc();
+
+  while (!MI.getOperand(i).isFI()) {
+    ++i;
+    assert(i < MI.getNumOperands() && "Instr doesn't have FrameIndex operand!");
+  }
+
+  unsigned FrameReg = getFrameRegister(MF);
+  int FrameIndex = MI.getOperand(i).getIndex();
+
+  if (MI.getOpcode() == BPF::MOV_rr) {
+    int Offset = MF.getFrameInfo()->getObjectOffset(FrameIndex);
+
+    MI.getOperand(i).ChangeToRegister(FrameReg, false);
+
+    MachineBasicBlock &MBB = *MI.getParent();
+    unsigned reg = MI.getOperand(i - 1).getReg();
+    BuildMI(MBB, ++ II, dl, TII.get(BPF::ADD_ri), reg)
+       .addReg(reg).addImm(Offset);
+    return;
+  }
+
+  int Offset = MF.getFrameInfo()->getObjectOffset(FrameIndex) +
+               MI.getOperand(i+1).getImm();
+
+  if (!isInt<32>(Offset)) {
+    llvm_unreachable("bug in frame offset");
+  }
+
+  MI.getOperand(i).ChangeToRegister(FrameReg, false);
+  MI.getOperand(i+1).ChangeToImmediate(Offset);
+}
+
+void BPFRegisterInfo::
+processFunctionBeforeFrameFinalized(MachineFunction &MF) const {}
+
+bool BPFRegisterInfo::hasBasePointer(const MachineFunction &MF) const {
+   return false;
+}
+
+bool BPFRegisterInfo::needsStackRealignment(const MachineFunction &MF) const {
+  return false;
+}
+
+unsigned BPFRegisterInfo::getRARegister() const {
+  return BPF::R0;
+}
+
+unsigned BPFRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
+  return BPF::R10;
+}
+
+unsigned BPFRegisterInfo::getBaseRegister() const {
+  llvm_unreachable("What is the base register");
+  return 0;
+}
+
+unsigned BPFRegisterInfo::getEHExceptionRegister() const {
+  llvm_unreachable("What is the exception register");
+  return 0;
+}
+
+unsigned BPFRegisterInfo::getEHHandlerRegister() const {
+  llvm_unreachable("What is the exception handler register");
+  return 0;
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h
new file mode 100644
index 0000000..8aeb341
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h
@@ -0,0 +1,65 @@
+//===- BPFRegisterInfo.h - BPF Register Information Impl ------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file contains the BPF implementation of the TargetRegisterInfo class.
+
+#ifndef BPFREGISTERINFO_H
+#define BPFREGISTERINFO_H
+
+#include "llvm/Target/TargetRegisterInfo.h"
+
+#define GET_REGINFO_HEADER
+#include "BPFGenRegisterInfo.inc"
+
+namespace llvm {
+
+class TargetInstrInfo;
+class Type;
+
+struct BPFRegisterInfo : public BPFGenRegisterInfo {
+  const TargetInstrInfo &TII;
+
+  BPFRegisterInfo(const TargetInstrInfo &tii);
+
+  /// Code Generation virtual methods...
+  const uint16_t *getCalleeSavedRegs(const MachineFunction *MF = 0) const;
+
+  BitVector getReservedRegs(const MachineFunction &MF) const;
+
+  bool requiresRegisterScavenging(const MachineFunction &MF) const;
+
+  // llvm 3.2 defines it here
+  void eliminateCallFramePseudoInstr(MachineFunction &MF,
+                                     MachineBasicBlock &MBB,
+                                     MachineBasicBlock::iterator I) const {
+    // Discard ADJCALLSTACKDOWN, ADJCALLSTACKUP instructions.
+    MBB.erase(I);
+  }
+
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+  void eliminateFrameIndex(MachineBasicBlock::iterator MI,
+                           int SPAdj, unsigned FIOperandNum,
+                           RegScavenger *RS = NULL) const;
+#else
+  void eliminateFrameIndex(MachineBasicBlock::iterator II,
+                           int SPAdj, RegScavenger *RS = NULL) const;
+#endif
+
+  void processFunctionBeforeFrameFinalized(MachineFunction &MF) const;
+
+  bool hasBasePointer(const MachineFunction &MF) const;
+  bool needsStackRealignment(const MachineFunction &MF) const;
+
+  // Debug information queries.
+  unsigned getRARegister() const;
+  unsigned getFrameRegister(const MachineFunction &MF) const;
+  unsigned getBaseRegister() const;
+
+  // Exception handling queries.
+  unsigned getEHExceptionRegister() const;
+  unsigned getEHHandlerRegister() const;
+  int getDwarfRegNum(unsigned RegNum, bool isEH) const;
+};
+}
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td
new file mode 100644
index 0000000..fac0817
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td
@@ -0,0 +1,39 @@
+//===- BPFRegisterInfo.td - BPF Register defs ------------*- tablegen -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+//  Declarations that describe the BPF register file
+
+class BPFReg<string n> : Register<n> {
+  field bits<4> Num;
+  let Namespace = "BPF";
+}
+
+// Registers are identified with 4-bit ID numbers.
+// Ri - 64-bit integer registers
+class Ri<bits<4> num, string n> : BPFReg<n> {
+  let Num = num;
+}
+
+// Integer registers
+def R0 : Ri< 0, "r0">, DwarfRegNum<[0]>;
+def R1 : Ri< 1, "r1">, DwarfRegNum<[1]>;
+def R2 : Ri< 2, "r2">, DwarfRegNum<[2]>;
+def R3 : Ri< 3, "r3">, DwarfRegNum<[3]>;
+def R4 : Ri< 4, "r4">, DwarfRegNum<[4]>;
+def R5 : Ri< 5, "r5">, DwarfRegNum<[5]>;
+def R6 : Ri< 6, "r6">, DwarfRegNum<[6]>;
+def R7 : Ri< 7, "r7">, DwarfRegNum<[7]>;
+def R8 : Ri< 8, "r8">, DwarfRegNum<[8]>;
+def R9 : Ri< 9, "r9">, DwarfRegNum<[9]>;
+def R10 : Ri<10, "r10">, DwarfRegNum<[10]>;
+def R11 : Ri<11, "r11">, DwarfRegNum<[11]>;
+
+// Register classes.
+def GPR : RegisterClass<"BPF", [i64], 64, (add R1, R2, R3, R4, R5,
+                                           R6, R7, R8, R9, // callee saved
+                                           R0, // return value
+                                           R11,  // stack ptr
+                                           R10  // frame ptr
+                                          )>;
+
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp
new file mode 100644
index 0000000..6e98f6d
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp
@@ -0,0 +1,23 @@
+//===- BPFSubtarget.cpp - BPF Subtarget Information -----------*- C++ -*-=//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#include "BPF.h"
+#include "BPFSubtarget.h"
+#define GET_SUBTARGETINFO_TARGET_DESC
+#define GET_SUBTARGETINFO_CTOR
+#include "BPFGenSubtargetInfo.inc"
+using namespace llvm;
+
+void BPFSubtarget::anchor() { }
+
+BPFSubtarget::BPFSubtarget(const std::string &TT,
+                           const std::string &CPU, const std::string &FS)
+  : BPFGenSubtargetInfo(TT, CPU, FS)
+{
+  std::string CPUName = CPU;
+  if (CPUName.empty())
+    CPUName = "generic";
+
+  ParseSubtargetFeatures(CPUName, FS);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h b/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h
new file mode 100644
index 0000000..cd5d875
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h
@@ -0,0 +1,33 @@
+//=====-- BPFSubtarget.h - Define Subtarget for the BPF -----*- C++ -*--==//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef BPFSUBTARGET_H
+#define BPFSUBTARGET_H
+
+#include "llvm/Target/TargetSubtargetInfo.h"
+#include "llvm/Target/TargetMachine.h"
+
+#include <string>
+
+#define GET_SUBTARGETINFO_HEADER
+#include "BPFGenSubtargetInfo.inc"
+
+namespace llvm {
+
+class BPFSubtarget : public BPFGenSubtargetInfo {
+  virtual void anchor();
+public:
+  /// This constructor initializes the data members to match that
+  /// of the specified triple.
+  ///
+  BPFSubtarget(const std::string &TT, const std::string &CPU,
+                 const std::string &FS);
+  
+  /// ParseSubtargetFeatures - Parses features string setting specified 
+  /// subtarget options.  Definition of function is auto generated by tblgen.
+  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);
+};
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp b/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp
new file mode 100644
index 0000000..bd811fd
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp
@@ -0,0 +1,72 @@
+//===-- BPFTargetMachine.cpp - Define TargetMachine for BPF ---------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// Implements the info about BPF target spec.
+
+#include "BPF.h"
+#include "BPFTargetMachine.h"
+#include "llvm/PassManager.h"
+#include "llvm/CodeGen/Passes.h"
+#include "llvm/Support/FormattedStream.h"
+#include "llvm/Support/TargetRegistry.h"
+#include "llvm/Target/TargetOptions.h"
+using namespace llvm;
+
+extern "C" void LLVMInitializeBPFTarget() {
+  // Register the target.
+  RegisterTargetMachine<BPFTargetMachine> X(TheBPFTarget);
+}
+
+// DataLayout --> Little-endian, 64-bit pointer/ABI/alignment
+// The stack is always 8 byte aligned
+// On function prologue, the stack is created by decrementing
+// its pointer. Once decremented, all references are done with positive
+// offset from the stack/frame pointer.
+BPFTargetMachine::
+BPFTargetMachine(const Target &T, StringRef TT,
+                    StringRef CPU, StringRef FS, const TargetOptions &Options,
+                    Reloc::Model RM, CodeModel::Model CM,
+                    CodeGenOpt::Level OL)
+  : LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
+  Subtarget(TT, CPU, FS),
+  // x86-64 like
+  DL("e-p:64:64-s:64-f64:64:64-i64:64:64-n8:16:32:64-S128"),
+  InstrInfo(), TLInfo(*this), TSInfo(*this),
+  FrameLowering(Subtarget) {
+#if LLVM_VERSION_MINOR==4
+  initAsmInfo();
+#endif
+}
+namespace {
+/// BPF Code Generator Pass Configuration Options.
+class BPFPassConfig : public TargetPassConfig {
+public:
+  BPFPassConfig(BPFTargetMachine *TM, PassManagerBase &PM)
+    : TargetPassConfig(TM, PM) {}
+
+  BPFTargetMachine &getBPFTargetMachine() const {
+    return getTM<BPFTargetMachine>();
+  }
+
+  virtual bool addInstSelector();
+  virtual bool addPreEmitPass();
+};
+}
+
+TargetPassConfig *BPFTargetMachine::createPassConfig(PassManagerBase &PM) {
+  return new BPFPassConfig(this, PM);
+}
+
+// Install an instruction selector pass using
+// the ISelDag to gen BPF code.
+bool BPFPassConfig::addInstSelector() {
+  addPass(createBPFISelDag(getBPFTargetMachine()));
+
+  return false;
+}
+
+bool BPFPassConfig::addPreEmitPass() {
+  addPass(createBPFCFGFixup(getBPFTargetMachine()));
+  return true;
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h b/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h
new file mode 100644
index 0000000..1d6b070
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h
@@ -0,0 +1,69 @@
+//===-- BPFTargetMachine.h - Define TargetMachine for BPF --- C++ ---===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file declares the BPF specific subclass of TargetMachine.
+
+#ifndef BPF_TARGETMACHINE_H
+#define BPF_TARGETMACHINE_H
+
+#include "BPFSubtarget.h"
+#include "BPFInstrInfo.h"
+#include "BPFISelLowering.h"
+#include "llvm/Target/TargetSelectionDAGInfo.h"
+#include "BPFFrameLowering.h"
+#include "llvm/Target/TargetMachine.h"
+#if !defined(LLVM_VERSION_MINOR)
+#error "Uknown version"
+#endif
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+#include "llvm/IR/DataLayout.h"
+#else
+#include "llvm/DataLayout.h"
+#endif
+#include "llvm/Target/TargetFrameLowering.h"
+
+namespace llvm {
+  class formatted_raw_ostream;
+
+  class BPFTargetMachine : public LLVMTargetMachine {
+    BPFSubtarget       Subtarget;
+    const DataLayout   DL; // Calculates type size & alignment
+    BPFInstrInfo       InstrInfo;
+    BPFTargetLowering  TLInfo;
+    TargetSelectionDAGInfo TSInfo;
+    BPFFrameLowering   FrameLowering;
+  public:
+    BPFTargetMachine(const Target &T, StringRef TT,
+                        StringRef CPU, StringRef FS,
+                        const TargetOptions &Options,
+                        Reloc::Model RM, CodeModel::Model CM,
+                        CodeGenOpt::Level OL);
+
+    virtual const BPFInstrInfo *getInstrInfo() const
+    { return &InstrInfo; }
+
+    virtual const TargetFrameLowering *getFrameLowering() const
+    { return &FrameLowering; }
+
+    virtual const BPFSubtarget *getSubtargetImpl() const
+    { return &Subtarget; }
+
+    virtual const DataLayout *getDataLayout() const
+    { return &DL;}
+
+    virtual const BPFRegisterInfo *getRegisterInfo() const
+    { return &InstrInfo.getRegisterInfo(); }
+
+    virtual const BPFTargetLowering *getTargetLowering() const
+    { return &TLInfo; }
+
+    virtual const TargetSelectionDAGInfo* getSelectionDAGInfo() const
+    { return &TSInfo; }
+
+    // Pass Pipeline Configuration
+    virtual TargetPassConfig *createPassConfig(PassManagerBase &PM);
+  };
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp b/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp
new file mode 100644
index 0000000..89d5cdb
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp
@@ -0,0 +1,79 @@
+//===-- BPFInstPrinter.cpp - Convert BPF MCInst to asm syntax -----------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This class prints an BPF MCInst to a .s file.
+
+#define DEBUG_TYPE "asm-printer"
+#include "BPF.h"
+#include "BPFInstPrinter.h"
+#include "llvm/MC/MCAsmInfo.h"
+#include "llvm/MC/MCExpr.h"
+#include "llvm/MC/MCInst.h"
+#include "llvm/MC/MCSymbol.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/FormattedStream.h"
+using namespace llvm;
+
+
+// Include the auto-generated portion of the assembly writer.
+#include "BPFGenAsmWriter.inc"
+
+void BPFInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
+                                StringRef Annot) {
+  printInstruction(MI, O);
+  printAnnotation(O, Annot);
+}
+
+static void printExpr(const MCExpr *Expr, raw_ostream &O) {
+  const MCSymbolRefExpr *SRE;
+
+  if (const MCBinaryExpr *BE = dyn_cast<MCBinaryExpr>(Expr))
+    SRE = dyn_cast<MCSymbolRefExpr>(BE->getLHS());
+  else
+    SRE = dyn_cast<MCSymbolRefExpr>(Expr);
+  assert(SRE && "Unexpected MCExpr type.");
+
+  MCSymbolRefExpr::VariantKind Kind = SRE->getKind();
+
+  assert(Kind == MCSymbolRefExpr::VK_None);
+  O << *Expr;
+}
+
+void BPFInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
+                                   raw_ostream &O, const char *Modifier) {
+  assert((Modifier == 0 || Modifier[0] == 0) && "No modifiers supported");
+  const MCOperand &Op = MI->getOperand(OpNo);
+  if (Op.isReg()) {
+    O << getRegisterName(Op.getReg());
+  } else if (Op.isImm()) {
+    O << (int32_t)Op.getImm();
+  } else {
+    assert(Op.isExpr() && "Expected an expression");
+    printExpr(Op.getExpr(), O);
+  }
+}
+
+void BPFInstPrinter::printMemOperand(const MCInst *MI, int OpNo,
+                                      raw_ostream &O, const char *Modifier) {
+  const MCOperand &RegOp = MI->getOperand(OpNo);
+  const MCOperand &OffsetOp = MI->getOperand(OpNo+1);
+  // offset
+  if (OffsetOp.isImm()) {
+    O << OffsetOp.getImm();
+  } else {
+    assert(0 && "Expected an immediate");
+//    assert(OffsetOp.isExpr() && "Expected an expression");
+//    printExpr(OffsetOp.getExpr(), O);
+  }
+  // register
+  assert(RegOp.isReg() && "Register operand not a register");
+  O  << "(" << getRegisterName(RegOp.getReg()) << ")";
+}
+
+void BPFInstPrinter::printS32ImmOperand(const MCInst *MI, unsigned OpNo,
+                                         raw_ostream &O) {
+  const MCOperand &Op = MI->getOperand(OpNo);
+  assert(Op.isImm() && "Immediate operand not an immediate");
+  O << (int32_t)Op.getImm();
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.h b/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.h
new file mode 100644
index 0000000..4f0cba5
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.h
@@ -0,0 +1,34 @@
+//= BPFInstPrinter.h - Convert BPF MCInst to asm syntax ---------*- C++ -*--//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This class prints a BPF MCInst to a .s file.
+
+#ifndef BPFINSTPRINTER_H
+#define BPFINSTPRINTER_H
+
+#include "llvm/MC/MCInstPrinter.h"
+
+namespace llvm {
+  class MCOperand;
+
+  class BPFInstPrinter : public MCInstPrinter {
+  public:
+    BPFInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
+                    const MCRegisterInfo &MRI)
+      : MCInstPrinter(MAI, MII, MRI) {}
+
+    void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot);
+    void printOperand(const MCInst *MI, unsigned OpNo,
+                      raw_ostream &O, const char *Modifier = 0);
+    void printMemOperand(const MCInst *MI, int OpNo,raw_ostream &O,
+                         const char *Modifier = 0);
+    void printS32ImmOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
+
+    // Autogenerated by tblgen.
+    void printInstruction(const MCInst *MI, raw_ostream &O);
+    static const char *getRegisterName(unsigned RegNo);
+  };
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp
new file mode 100644
index 0000000..8d5b5c9
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp
@@ -0,0 +1,85 @@
+//===-- BPFAsmBackend.cpp - BPF Assembler Backend -----------------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#include "MCTargetDesc/BPFMCTargetDesc.h"
+#include "llvm/MC/MCAsmBackend.h"
+#include "llvm/MC/MCAssembler.h"
+#include "llvm/MC/MCDirectives.h"
+#include "llvm/MC/MCELFObjectWriter.h"
+#include "llvm/MC/MCFixupKindInfo.h"
+#include "llvm/MC/MCObjectWriter.h"
+#include "llvm/MC/MCSubtargetInfo.h"
+#include "llvm/MC/MCExpr.h"
+#include "llvm/MC/MCSymbol.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/raw_ostream.h"
+
+using namespace llvm;
+
+namespace {
+class BPFAsmBackend : public MCAsmBackend {
+public:
+  BPFAsmBackend(): MCAsmBackend() {}
+  virtual ~BPFAsmBackend() {}
+
+  void applyFixup(const MCFixup &Fixup, char *Data, unsigned DataSize,
+                  uint64_t Value) const;
+
+  MCObjectWriter *createObjectWriter(raw_ostream &OS) const;
+
+  // No instruction requires relaxation
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
+                            const MCRelaxableFragment *DF,
+                            const MCAsmLayout &Layout) const { return false; }
+#else
+  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value, 
+                            const MCInstFragment *DF,
+                            const MCAsmLayout &Layout) const { return false; }
+#endif
+  
+  unsigned getNumFixupKinds() const { return 1; }
+
+  bool mayNeedRelaxation(const MCInst &Inst) const { return false; }
+
+  void relaxInstruction(const MCInst &Inst, MCInst &Res) const {}
+
+  bool writeNopData(uint64_t Count, MCObjectWriter *OW) const;
+};
+
+bool BPFAsmBackend::writeNopData(uint64_t Count, MCObjectWriter *OW) const {
+  if ((Count % 8) != 0)
+    return false;
+
+  for (uint64_t i = 0; i < Count; i += 8)
+    OW->Write64(0x15000000);
+
+  return true;
+}
+
+void BPFAsmBackend::applyFixup(const MCFixup &Fixup, char *Data,
+                               unsigned DataSize, uint64_t Value) const {
+
+  assert (Fixup.getKind() == FK_PCRel_2);
+  *(uint16_t*)&Data[Fixup.getOffset() + 2] = (uint16_t) ((Value - 8) / 8);
+
+  if (0)
+   errs() << "<MCFixup" << " Offset:" << Fixup.getOffset() << " Value:" <<
+     *(Fixup.getValue()) << " Kind:" << Fixup.getKind() <<
+     " val " << Value << ">\n";
+}
+
+MCObjectWriter *BPFAsmBackend::createObjectWriter(raw_ostream &OS) const {
+  return createBPFELFObjectWriter(OS, 0);
+}
+
+}
+
+MCAsmBackend *llvm::createBPFAsmBackend(const Target &T,
+#if LLVM_VERSION_MINOR==4
+                                        const MCRegisterInfo &MRI,
+#endif
+                                        StringRef TT, StringRef CPU) {
+  return new BPFAsmBackend();
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h
new file mode 100644
index 0000000..9d03073
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h
@@ -0,0 +1,33 @@
+//===-- BPFBaseInfo.h - Top level definitions for BPF MC ------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+#ifndef BPFBASEINFO_H
+#define BPFBASEINFO_H
+
+#include "BPFMCTargetDesc.h"
+#include "llvm/MC/MCExpr.h"
+#include "llvm/Support/DataTypes.h"
+#include "llvm/Support/ErrorHandling.h"
+
+namespace llvm {
+
+static inline unsigned getBPFRegisterNumbering(unsigned Reg) {
+  switch(Reg) {
+    case BPF::R0  : return 0;
+    case BPF::R1  : return 1;
+    case BPF::R2  : return 2;
+    case BPF::R3  : return 3;
+    case BPF::R4  : return 4;
+    case BPF::R5  : return 5;
+    case BPF::R6  : return 6;
+    case BPF::R7  : return 7;
+    case BPF::R8  : return 8;
+    case BPF::R9  : return 9;
+    case BPF::R10 : return 10;
+    case BPF::R11 : return 11;
+    default: llvm_unreachable("Unknown register number!");
+  }
+}
+
+}
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp
new file mode 100644
index 0000000..22cf0d6
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp
@@ -0,0 +1,119 @@
+//===-- BPFELFObjectWriter.cpp - BPF Writer -------------------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#include "MCTargetDesc/BPFBaseInfo.h"
+#include "MCTargetDesc/BPFMCTargetDesc.h"
+#include "MCTargetDesc/BPFMCCodeEmitter.h"
+#include "llvm/MC/MCObjectWriter.h"
+#include "llvm/MC/MCValue.h"
+#include "llvm/MC/MCAssembler.h"
+#include "llvm/MC/MCSectionELF.h"
+#include "llvm/MC/MCAsmLayout.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/raw_ostream.h"
+
+using namespace llvm;
+
+namespace {
+class BPFObjectWriter : public MCObjectWriter {
+  public:
+    BPFObjectWriter(raw_ostream &_OS):
+      MCObjectWriter(_OS, true/*isLittleEndian*/) {}
+    virtual ~BPFObjectWriter() {}
+    virtual void WriteObject(MCAssembler &Asm, const MCAsmLayout &Layout);
+    virtual void RecordRelocation(const MCAssembler &Asm,
+                                  const MCAsmLayout &Layout,
+                                  const MCFragment *Fragment,
+                                  const MCFixup &Fixup,
+                                  MCValue Target, uint64_t &FixedValue) {}
+    virtual void ExecutePostLayoutBinding(MCAssembler &Asm,
+                                          const MCAsmLayout &Layout) {}
+
+};
+}
+
+static void WriteSectionData(MCAssembler &Asm, const MCSectionData &SD) {
+  MCObjectWriter *OW = &Asm.getWriter();
+  for (MCSectionData::const_iterator it = SD.begin(),
+         ie = SD.end(); it != ie; ++it) {
+    const MCFragment &F = *it;
+    switch (F.getKind()) {
+    case MCFragment::FT_Align:
+      continue;
+    case MCFragment::FT_Data: {
+      const MCDataFragment &DF = cast<MCDataFragment>(F);
+      OW->WriteBytes(DF.getContents());
+      break;
+    }
+    case MCFragment::FT_Fill: {
+      const MCFillFragment &FF = cast<MCFillFragment>(F);
+
+      assert(FF.getValueSize() && "Invalid virtual align in concrete fragment!");
+
+      for (uint64_t i = 0, e = FF.getSize() / FF.getValueSize(); i != e; ++i) {
+        switch (FF.getValueSize()) {
+        default: llvm_unreachable("Invalid size!");
+        case 1: OW->Write8 (uint8_t (FF.getValue())); break;
+        case 2: OW->Write16(uint16_t(FF.getValue())); break;
+        case 4: OW->Write32(uint32_t(FF.getValue())); break;
+        case 8: OW->Write64(uint64_t(FF.getValue())); break;
+        }
+      }
+      break;
+    }
+    default:
+      errs() << "MCFrag " << F.getKind() << "\n";
+    }
+  }
+}
+
+void BPFObjectWriter::WriteObject(MCAssembler &Asm,
+                                  const MCAsmLayout &Layout) {
+  bool LicenseSeen = false;
+  MCObjectWriter *OW = &Asm.getWriter();
+  OW->WriteBytes(StringRef("bpf"), 4);
+
+  BPFMCCodeEmitter *CE = (BPFMCCodeEmitter*)(&Asm.getEmitter());
+//  Asm.dump();
+  for (MCAssembler::const_iterator i = Asm.begin(), e = Asm.end(); i != e;
+       ++i) {
+    const MCSectionELF &Section =
+      static_cast<const MCSectionELF&>(i->getSection());
+    const StringRef SectionName = Section.getSectionName();
+    const MCSectionData &SD = Asm.getSectionData(Section);
+    int SectionSize = Layout.getSectionAddressSize(&SD);
+    if (SectionSize > 0) {
+      CE->getStrtabIndex(SectionName);
+      if (SectionName == "license")
+        LicenseSeen = true;
+    }
+  }
+
+  if (!LicenseSeen)
+      report_fatal_error("BPF source is missing license");
+
+  OW->Write32(CE->Strtab->length());
+  OW->WriteBytes(StringRef(*CE->Strtab));
+
+  for (MCAssembler::const_iterator i = Asm.begin(), e = Asm.end(); i != e;
+       ++i) {
+    const MCSectionELF &Section =
+      static_cast<const MCSectionELF&>(i->getSection());
+    const StringRef SectionName = Section.getSectionName();
+    const MCSectionData &SD = Asm.getSectionData(Section);
+    int SectionSize = Layout.getSectionAddressSize(&SD);
+    if (SectionSize > 0 &&
+        /* ignore .rodata.* for now */
+        !(Section.getFlags() & ELF::SHF_STRINGS)) {
+      OW->Write32(SectionSize);
+      OW->Write32(CE->getStrtabIndex(SectionName));
+      WriteSectionData(Asm, SD);
+    }
+  }
+}
+
+MCObjectWriter *llvm::createBPFELFObjectWriter(raw_ostream &OS,
+                                               uint8_t OSABI) {
+  return new BPFObjectWriter(OS);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h
new file mode 100644
index 0000000..99132ee
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h
@@ -0,0 +1,34 @@
+//=====-- BPFMCAsmInfo.h - BPF asm properties -----------*- C++ -*--====//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#ifndef BPF_MCASM_INFO_H
+#define BPF_MCASM_INFO_H
+
+#include "llvm/ADT/StringRef.h"
+#include "llvm/MC/MCAsmInfo.h"
+
+namespace llvm {
+  class Target;
+  
+  class BPFMCAsmInfo : public MCAsmInfo {
+  public:
+#if LLVM_VERSION_MINOR==4
+    explicit BPFMCAsmInfo(StringRef TT) {
+#else
+    explicit BPFMCAsmInfo(const Target &T, StringRef TT) {
+#endif
+      PrivateGlobalPrefix         = ".L";
+      WeakRefDirective            = "\t.weak\t";
+
+      // BPF assembly requires ".section" before ".bss"
+      UsesELFSectionDirectiveForBSS = true;
+
+      HasSingleParameterDotFile = false;
+      HasDotTypeDotSizeDirective = false;
+    }
+  };
+
+}
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp
new file mode 100644
index 0000000..9e3f52c
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp
@@ -0,0 +1,120 @@
+//===-- BPFMCCodeEmitter.cpp - Convert BPF code to machine code ---------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#define DEBUG_TYPE "mccodeemitter"
+#include "MCTargetDesc/BPFBaseInfo.h"
+#include "MCTargetDesc/BPFMCTargetDesc.h"
+#include "MCTargetDesc/BPFMCCodeEmitter.h"
+#include "llvm/MC/MCCodeEmitter.h"
+#include "llvm/MC/MCFixup.h"
+#include "llvm/MC/MCInst.h"
+#include "llvm/MC/MCInstrInfo.h"
+#include "llvm/MC/MCRegisterInfo.h"
+#include "llvm/MC/MCSubtargetInfo.h"
+#include "llvm/MC/MCSymbol.h"
+#include "llvm/ADT/Statistic.h"
+#include "llvm/Support/raw_ostream.h"
+using namespace llvm;
+
+STATISTIC(MCNumEmitted, "Number of MC instructions emitted");
+
+MCCodeEmitter *llvm::createBPFMCCodeEmitter(const MCInstrInfo &MCII,
+                                             const MCRegisterInfo &MRI,
+                                             const MCSubtargetInfo &STI,
+                                             MCContext &Ctx) {
+  return new BPFMCCodeEmitter(MCII, STI, Ctx);
+}
+
+/// getMachineOpValue - Return binary encoding of operand. If the machine
+/// operand requires relocation, record the relocation and return zero.
+unsigned BPFMCCodeEmitter::
+getMachineOpValue(const MCInst &MI, const MCOperand &MO,
+                  SmallVectorImpl<MCFixup> &Fixups) const {
+  if (MO.isReg())
+    return getBPFRegisterNumbering(MO.getReg());
+  if (MO.isImm())
+    return static_cast<unsigned>(MO.getImm());
+  
+  assert(MO.isExpr());
+
+  const MCExpr *Expr = MO.getExpr();
+  MCExpr::ExprKind Kind = Expr->getKind();
+
+/*  if (Kind == MCExpr::Binary) {
+    Expr = static_cast<const MCBinaryExpr*>(Expr)->getLHS();
+    Kind = Expr->getKind();
+  }*/
+
+  assert (Kind == MCExpr::SymbolRef);
+
+  if (MI.getOpcode() == BPF::JAL) {
+    /* func call name */
+//    Fixups.push_back(MCFixup::Create(0, MO.getExpr(), FK_SecRel_4));
+    const MCSymbolRefExpr *SRE = dyn_cast<MCSymbolRefExpr>(Expr);
+    return getStrtabIndex(SRE->getSymbol().getName());
+
+  } else {
+    /* bb label */
+    Fixups.push_back(MCFixup::Create(0, MO.getExpr(), FK_PCRel_2));
+    return 0;
+  }
+}
+
+// Emit one byte through output stream
+void EmitByte(unsigned char C, unsigned &CurByte, raw_ostream &OS) {
+  OS << (char)C;
+  ++CurByte;
+}
+
+// Emit a series of bytes (little endian)
+void EmitLEConstant(uint64_t Val, unsigned Size, unsigned &CurByte,
+                    raw_ostream &OS) {
+  assert(Size <= 8 && "size too big in emit constant");
+
+  for (unsigned i = 0; i != Size; ++i) {
+    EmitByte(Val & 255, CurByte, OS);
+    Val >>= 8;
+  }
+}
+
+// Emit a series of bytes (big endian)
+void EmitBEConstant(uint64_t Val, unsigned Size, unsigned &CurByte,
+                    raw_ostream &OS) {
+  assert(Size <= 8 && "size too big in emit constant");
+
+  for (int i = (Size-1)*8; i >= 0; i-=8)
+    EmitByte((Val >> i) & 255, CurByte, OS);
+}
+
+void BPFMCCodeEmitter::EncodeInstruction(const MCInst &MI, raw_ostream &OS,
+                                         SmallVectorImpl<MCFixup> &Fixups) const {
+//  unsigned Opcode = MI.getOpcode();
+//  const MCInstrDesc &Desc = MCII.get(Opcode);
+  // Keep track of the current byte being emitted
+  unsigned CurByte = 0;
+
+  // Get instruction encoding and emit it
+  ++MCNumEmitted;       // Keep track of the number of emitted insns.
+  uint64_t Value = getBinaryCodeForInstr(MI, Fixups);
+  EmitByte(Value >> 56, CurByte, OS);
+  EmitByte((Value >> 48) & 0xff, CurByte, OS);
+  EmitLEConstant((Value >> 32) & 0xffff, 2, CurByte, OS);
+  EmitLEConstant(Value & 0xffffFFFF, 4, CurByte, OS);
+}
+
+// Encode BPF Memory Operand
+uint64_t BPFMCCodeEmitter::getMemoryOpValue(const MCInst &MI, unsigned Op,
+                                            SmallVectorImpl<MCFixup> &Fixups) const {
+  uint64_t encoding;
+  const MCOperand op1 = MI.getOperand(1);
+  assert(op1.isReg() && "First operand is not register.");
+  encoding = getBPFRegisterNumbering(op1.getReg());
+  encoding <<= 16;
+  MCOperand op2 = MI.getOperand(2);
+  assert(op2.isImm() && "Second operand is not immediate.");
+  encoding |= op2.getImm() & 0xffff;
+  return encoding;
+}
+
+#include "BPFGenMCCodeEmitter.inc"
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h
new file mode 100644
index 0000000..84d86c0
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h
@@ -0,0 +1,67 @@
+//===-- BPFMCCodeEmitter.h - Convert BPF code to machine code ---------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#include "MCTargetDesc/BPFBaseInfo.h"
+#include "MCTargetDesc/BPFMCTargetDesc.h"
+#include "llvm/MC/MCCodeEmitter.h"
+#include "llvm/MC/MCFixup.h"
+#include "llvm/MC/MCInst.h"
+#include "llvm/MC/MCInstrInfo.h"
+#include "llvm/MC/MCRegisterInfo.h"
+#include "llvm/MC/MCSubtargetInfo.h"
+#include "llvm/MC/MCSymbol.h"
+#include "llvm/ADT/Statistic.h"
+#include "llvm/Support/raw_ostream.h"
+using namespace llvm;
+
+namespace {
+class BPFMCCodeEmitter : public MCCodeEmitter {
+  BPFMCCodeEmitter(const BPFMCCodeEmitter &);
+  void operator=(const BPFMCCodeEmitter &);
+  const MCInstrInfo &MCII;
+  const MCSubtargetInfo &STI;
+  MCContext &Ctx;
+
+public:
+  BPFMCCodeEmitter(const MCInstrInfo &mcii, const MCSubtargetInfo &sti,
+                    MCContext &ctx)
+    : MCII(mcii), STI(sti), Ctx(ctx) {
+      Strtab = new std::string;
+      Strtab->push_back('\0');
+    }
+
+  ~BPFMCCodeEmitter() {delete Strtab;}
+
+  std::string *Strtab;
+
+  int getStrtabIndex(const StringRef Name) const {
+    std::string Sym = Name.str();
+    Sym.push_back('\0');
+
+    std::string::size_type pos = Strtab->find(Sym);
+    if (pos == std::string::npos) {
+      Strtab->append(Sym);
+      pos = Strtab->find(Sym);
+      assert (pos != std::string::npos);
+    }
+    return pos;
+  }
+
+  // getBinaryCodeForInstr - TableGen'erated function for getting the
+  // binary encoding for an instruction.
+  uint64_t getBinaryCodeForInstr(const MCInst &MI,
+                                 SmallVectorImpl<MCFixup> &Fixups) const;
+
+   // getMachineOpValue - Return binary encoding of operand. If the machin
+   // operand requires relocation, record the relocation and return zero.
+  unsigned getMachineOpValue(const MCInst &MI,const MCOperand &MO,
+                             SmallVectorImpl<MCFixup> &Fixups) const;
+
+  uint64_t getMemoryOpValue(const MCInst &MI, unsigned Op,
+                            SmallVectorImpl<MCFixup> &Fixups) const;
+
+  void EncodeInstruction(const MCInst &MI, raw_ostream &OS,
+                         SmallVectorImpl<MCFixup> &Fixups) const;
+};
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp
new file mode 100644
index 0000000..db043d7
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp
@@ -0,0 +1,115 @@
+//===-- BPFMCTargetDesc.cpp - BPF Target Descriptions -----------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file provides BPF specific target descriptions.
+
+#include "BPF.h"
+#include "BPFMCTargetDesc.h"
+#include "BPFMCAsmInfo.h"
+#include "InstPrinter/BPFInstPrinter.h"
+#include "llvm/MC/MCCodeGenInfo.h"
+#include "llvm/MC/MCInstrInfo.h"
+#include "llvm/MC/MCRegisterInfo.h"
+#include "llvm/MC/MCStreamer.h"
+#include "llvm/MC/MCSubtargetInfo.h"
+#include "llvm/Support/ErrorHandling.h"
+#include "llvm/Support/TargetRegistry.h"
+
+#define GET_INSTRINFO_MC_DESC
+#include "BPFGenInstrInfo.inc"
+
+#define GET_SUBTARGETINFO_MC_DESC
+#include "BPFGenSubtargetInfo.inc"
+
+#define GET_REGINFO_MC_DESC
+#include "BPFGenRegisterInfo.inc"
+
+using namespace llvm;
+
+static MCInstrInfo *createBPFMCInstrInfo() {
+  MCInstrInfo *X = new MCInstrInfo();
+  InitBPFMCInstrInfo(X);
+  return X;
+}
+
+static MCRegisterInfo *createBPFMCRegisterInfo(StringRef TT) {
+  MCRegisterInfo *X = new MCRegisterInfo();
+  InitBPFMCRegisterInfo(X, BPF::R9);
+  return X;
+}
+
+static MCSubtargetInfo *createBPFMCSubtargetInfo(StringRef TT, StringRef CPU,
+                                                   StringRef FS) {
+  MCSubtargetInfo *X = new MCSubtargetInfo();
+  InitBPFMCSubtargetInfo(X, TT, CPU, FS);
+  return X;
+}
+
+static MCCodeGenInfo *createBPFMCCodeGenInfo(StringRef TT, Reloc::Model RM,
+                                               CodeModel::Model CM,
+                                               CodeGenOpt::Level OL) {
+  MCCodeGenInfo *X = new MCCodeGenInfo();
+  X->InitMCCodeGenInfo(RM, CM, OL);
+  return X;
+}
+
+static MCStreamer *createBPFMCStreamer(const Target &T, StringRef TT,
+                                    MCContext &Ctx, MCAsmBackend &MAB,
+                                    raw_ostream &_OS,
+                                    MCCodeEmitter *_Emitter,
+                                    bool RelaxAll,
+                                    bool NoExecStack) {
+#if LLVM_VERSION_MINOR==4
+  return createELFStreamer(Ctx, 0, MAB, _OS, _Emitter, RelaxAll, NoExecStack);
+#else
+  return createELFStreamer(Ctx, MAB, _OS, _Emitter, RelaxAll, NoExecStack);
+#endif
+}
+
+static MCInstPrinter *createBPFMCInstPrinter(const Target &T,
+                                              unsigned SyntaxVariant,
+                                              const MCAsmInfo &MAI,
+                                              const MCInstrInfo &MII,
+                                              const MCRegisterInfo &MRI,
+                                              const MCSubtargetInfo &STI) {
+  if (SyntaxVariant == 0)
+    return new BPFInstPrinter(MAI, MII, MRI);
+  return 0;
+}
+
+extern "C" void LLVMInitializeBPFTargetMC() {
+  // Register the MC asm info.
+  RegisterMCAsmInfo<BPFMCAsmInfo> X(TheBPFTarget);
+
+  // Register the MC codegen info.
+  TargetRegistry::RegisterMCCodeGenInfo(TheBPFTarget,
+                                       createBPFMCCodeGenInfo);
+
+  // Register the MC instruction info.
+  TargetRegistry::RegisterMCInstrInfo(TheBPFTarget, createBPFMCInstrInfo);
+
+  // Register the MC register info.
+  TargetRegistry::RegisterMCRegInfo(TheBPFTarget, createBPFMCRegisterInfo);
+
+  // Register the MC subtarget info.
+  TargetRegistry::RegisterMCSubtargetInfo(TheBPFTarget,
+                                          createBPFMCSubtargetInfo);
+
+  // Register the MC code emitter
+  TargetRegistry::RegisterMCCodeEmitter(TheBPFTarget,
+                                        llvm::createBPFMCCodeEmitter);
+
+  // Register the ASM Backend
+  TargetRegistry::RegisterMCAsmBackend(TheBPFTarget,
+                                       createBPFAsmBackend);
+
+  // Register the object streamer
+  TargetRegistry::RegisterMCObjectStreamer(TheBPFTarget,
+                                           createBPFMCStreamer);
+
+
+  // Register the MCInstPrinter.
+  TargetRegistry::RegisterMCInstPrinter(TheBPFTarget,
+                                        createBPFMCInstPrinter);
+}
diff --git a/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h
new file mode 100644
index 0000000..b337a00
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h
@@ -0,0 +1,56 @@
+//===-- BPFMCTargetDesc.h - BPF Target Descriptions -----------*- C++ -*-===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This file provides BPF specific target descriptions.
+
+#ifndef BPFMCTARGETDESC_H
+#define BPFMCTARGETDESC_H
+
+#include "llvm/Support/DataTypes.h"
+#include "llvm/Config/config.h"
+
+namespace llvm {
+class MCAsmBackend;
+class MCCodeEmitter;
+class MCContext;
+class MCInstrInfo;
+class MCObjectWriter;
+class MCRegisterInfo;
+class MCSubtargetInfo;
+class Target;
+class StringRef;
+class raw_ostream;
+
+extern Target TheBPFTarget;
+
+MCCodeEmitter *createBPFMCCodeEmitter(const MCInstrInfo &MCII,
+                                       const MCRegisterInfo &MRI,
+                                       const MCSubtargetInfo &STI,
+                                       MCContext &Ctx);
+
+MCAsmBackend *createBPFAsmBackend(const Target &T,
+#if LLVM_VERSION_MINOR==4
+                                  const MCRegisterInfo &MRI,
+#endif
+                                  StringRef TT, StringRef CPU);
+
+
+MCObjectWriter *createBPFELFObjectWriter(raw_ostream &OS, uint8_t OSABI);
+}
+
+// Defines symbolic names for BPF registers.  This defines a mapping from
+// register name to register number.
+//
+#define GET_REGINFO_ENUM
+#include "BPFGenRegisterInfo.inc"
+
+// Defines symbolic names for the BPF instructions.
+//
+#define GET_INSTRINFO_ENUM
+#include "BPFGenInstrInfo.inc"
+
+#define GET_SUBTARGETINFO_ENUM
+#include "BPFGenSubtargetInfo.inc"
+
+#endif
diff --git a/tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp b/tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp
new file mode 100644
index 0000000..4d16305
--- /dev/null
+++ b/tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp
@@ -0,0 +1,13 @@
+//===-- BPFTargetInfo.cpp - BPF Target Implementation -----------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+
+#include "BPF.h"
+#include "llvm/Support/TargetRegistry.h"
+using namespace llvm;
+
+Target llvm::TheBPFTarget;
+
+extern "C" void LLVMInitializeBPFTargetInfo() {
+  RegisterTarget<Triple::x86_64> X(TheBPFTarget, "bpf", "BPF");
+}
diff --git a/tools/bpf/llvm/tools/llc/llc.cpp b/tools/bpf/llvm/tools/llc/llc.cpp
new file mode 100644
index 0000000..517a7a8
--- /dev/null
+++ b/tools/bpf/llvm/tools/llc/llc.cpp
@@ -0,0 +1,381 @@
+//===-- llc.cpp - Implement the LLVM Native Code Generator ----------------===//
+// This file is distributed under the University of Illinois Open Source
+// License. See LICENSE.TXT for details.
+//
+// This is the llc code generator driver. It provides a convenient
+// command-line interface for generating native assembly-language code
+// or C code, given LLVM bitcode.
+
+#include "llvm/Config/config.h"
+#undef LLVM_NATIVE_TARGET
+#undef LLVM_NATIVE_ASMPRINTER
+#undef LLVM_NATIVE_ASMPARSER
+#undef LLVM_NATIVE_DISASSEMBLER
+#if LLVM_VERSION_MINOR==3 || LLVM_VERSION_MINOR==4
+#include "llvm/IR/LLVMContext.h"
+#include "llvm/IR/Module.h"
+#include "llvm/IR/DataLayout.h"
+#include "llvm/IRReader/IRReader.h"
+#include "llvm/Support/SourceMgr.h"
+#else
+#include "llvm/LLVMContext.h"
+#include "llvm/Module.h"
+#include "llvm/DataLayout.h"
+#include "llvm/Support/IRReader.h"
+#endif
+#include "llvm/PassManager.h"
+#include "llvm/Pass.h"
+#include "llvm/ADT/Triple.h"
+#include "llvm/Assembly/PrintModulePass.h"
+#include "llvm/CodeGen/LinkAllAsmWriterComponents.h"
+#include "llvm/CodeGen/LinkAllCodegenComponents.h"
+#include "llvm/MC/SubtargetFeature.h"
+#include "llvm/Support/CommandLine.h"
+#include "llvm/Support/Debug.h"
+#include "llvm/Support/FormattedStream.h"
+#include "llvm/Support/ManagedStatic.h"
+#include "llvm/Support/PluginLoader.h"
+#include "llvm/Support/PrettyStackTrace.h"
+#include "llvm/Support/ToolOutputFile.h"
+#include "llvm/Support/Host.h"
+#include "llvm/Support/Signals.h"
+#include "llvm/Support/TargetRegistry.h"
+#include "llvm/Support/TargetSelect.h"
+#include "llvm/Target/TargetLibraryInfo.h"
+#include "llvm/Target/TargetMachine.h"
+#include <memory>
+using namespace llvm;
+
+extern "C" {
+void AnnotateHappensBefore(const char *file, int line,
+                           const volatile void *cv) {}
+void AnnotateHappensAfter(const char *file, int line,
+                          const volatile void *cv) {}
+void AnnotateIgnoreWritesBegin(const char *file, int line) {}
+void AnnotateIgnoreWritesEnd(const char *file, int line) {}
+}
+
+__attribute__((weak)) bool llvm::DebugFlag;
+
+__attribute__((weak)) bool llvm::isCurrentDebugType(const char *Type) {
+ return false;
+}
+
+// General options for llc.  Other pass-specific options are specified
+// within the corresponding llc passes, and target-specific options
+// and back-end code generation options are specified with the target machine.
+//
+static cl::opt<std::string>
+InputFilename(cl::Positional, cl::desc("<input bitcode>"), cl::init("-"));
+
+static cl::opt<std::string>
+OutputFilename("o", cl::desc("Output filename"), cl::value_desc("filename"));
+
+// Determine optimization level.
+static cl::opt<char>
+OptLevel("O",
+         cl::desc("Optimization level. [-O0, -O1, -O2, or -O3] "
+                  "(default = '-O2')"),
+         cl::Prefix,
+         cl::ZeroOrMore,
+         cl::init(' '));
+
+static cl::opt<std::string>
+TargetTriple("mtriple", cl::desc("Override target triple for module"));
+
+static cl::list<std::string>
+MAttrs("mattr",
+  cl::CommaSeparated,
+  cl::desc("Target specific attributes (-mattr=help for details)"),
+  cl::value_desc("a1,+a2,-a3,..."));
+
+cl::opt<TargetMachine::CodeGenFileType>
+FileType("filetype", cl::init(TargetMachine::CGFT_ObjectFile),
+  cl::desc("Choose a file type (not all types are supported by all targets):"),
+  cl::values(
+       clEnumValN(TargetMachine::CGFT_AssemblyFile, "asm",
+                  "Emit an assembly ('.s') file"),
+       clEnumValN(TargetMachine::CGFT_ObjectFile, "obj",
+                  "Emit a native object ('.o') file"),
+       clEnumValN(TargetMachine::CGFT_Null, "null",
+                  "Emit nothing, for performance testing"),
+       clEnumValEnd));
+
+cl::opt<bool> NoVerify("disable-verify", cl::Hidden,
+                       cl::desc("Do not verify input module"));
+
+static cl::opt<bool>
+DontPlaceZerosInBSS("nozero-initialized-in-bss",
+  cl::desc("Don't place zero-initialized symbols into bss section"),
+  cl::init(false));
+
+static cl::opt<bool>
+DisableSimplifyLibCalls("disable-simplify-libcalls",
+  cl::desc("Disable simplify-libcalls"),
+  cl::init(false));
+
+static cl::opt<bool>
+EnableGuaranteedTailCallOpt("tailcallopt",
+  cl::desc("Turn fastcc calls into tail calls by (potentially) changing ABI."),
+  cl::init(false));
+
+static cl::opt<bool>
+DisableTailCalls("disable-tail-calls",
+  cl::desc("Never emit tail calls"),
+  cl::init(false));
+
+static cl::opt<std::string> StopAfter("stop-after",
+  cl::desc("Stop compilation after a specific pass"),
+  cl::value_desc("pass-name"),
+  cl::init(""));
+static cl::opt<std::string> StartAfter("start-after",
+  cl::desc("Resume compilation after a specific pass"),
+  cl::value_desc("pass-name"),
+  cl::init(""));
+
+// GetFileNameRoot - Helper function to get the basename of a filename.
+static inline std::string
+GetFileNameRoot(const std::string &InputFilename) {
+  std::string IFN = InputFilename;
+  std::string outputFilename;
+  int Len = IFN.length();
+  if ((Len > 2) &&
+      IFN[Len-3] == '.' &&
+      ((IFN[Len-2] == 'b' && IFN[Len-1] == 'c') ||
+       (IFN[Len-2] == 'l' && IFN[Len-1] == 'l'))) {
+    outputFilename = std::string(IFN.begin(), IFN.end()-3); // s/.bc/.s/
+  } else {
+    outputFilename = IFN;
+  }
+  return outputFilename;
+}
+
+static tool_output_file *GetOutputStream(const char *TargetName,
+                                         Triple::OSType OS,
+                                         const char *ProgName) {
+  // If we don't yet have an output filename, make one.
+  if (OutputFilename.empty()) {
+    if (InputFilename == "-")
+      OutputFilename = "-";
+    else {
+      OutputFilename = GetFileNameRoot(InputFilename);
+
+      switch (FileType) {
+      case TargetMachine::CGFT_AssemblyFile:
+        if (TargetName[0] == 'c') {
+          if (TargetName[1] == 0)
+            OutputFilename += ".cbe.c";
+          else if (TargetName[1] == 'p' && TargetName[2] == 'p')
+            OutputFilename += ".cpp";
+          else
+            OutputFilename += ".s";
+        } else
+          OutputFilename += ".s";
+        break;
+      case TargetMachine::CGFT_ObjectFile:
+        OutputFilename += ".o";
+        break;
+      case TargetMachine::CGFT_Null:
+        OutputFilename += ".null";
+        break;
+      }
+    }
+  }
+
+  // Decide if we need "binary" output.
+  bool Binary = false;
+  switch (FileType) {
+  case TargetMachine::CGFT_AssemblyFile:
+    break;
+  case TargetMachine::CGFT_ObjectFile:
+  case TargetMachine::CGFT_Null:
+    Binary = true;
+    break;
+  }
+
+  // Open the file.
+  std::string error;
+#if LLVM_VERSION_MINOR==4
+  sys::fs::OpenFlags OpenFlags = sys::fs::F_None;
+  if (Binary)
+    OpenFlags |= sys::fs::F_Binary;
+#else
+  unsigned OpenFlags = 0;
+  if (Binary) OpenFlags |= raw_fd_ostream::F_Binary;
+#endif
+  tool_output_file *FDOut = new tool_output_file(OutputFilename.c_str(), error,
+                                                 OpenFlags);
+  if (!error.empty()) {
+    errs() << error << '\n';
+    delete FDOut;
+    return 0;
+  }
+
+  return FDOut;
+}
+
+// main - Entry point for the llc compiler.
+//
+int main(int argc, char **argv) {
+  sys::PrintStackTraceOnErrorSignal();
+  PrettyStackTraceProgram X(argc, argv);
+
+  // Enable debug stream buffering.
+  EnableDebugBuffering = true;
+
+  LLVMContext &Context = getGlobalContext();
+  llvm_shutdown_obj Y;  // Call llvm_shutdown() on exit.
+
+  // Initialize targets first, so that --version shows registered targets.
+  InitializeAllTargets();
+  InitializeAllTargetMCs();
+  InitializeAllAsmPrinters();
+  InitializeAllAsmParsers();
+
+  // Initialize codegen and IR passes used by llc so that the -print-after,
+  // -print-before, and -stop-after options work.
+  PassRegistry *Registry = PassRegistry::getPassRegistry();
+  initializeCore(*Registry);
+  initializeCodeGen(*Registry);
+  initializeLoopStrengthReducePass(*Registry);
+  initializeLowerIntrinsicsPass(*Registry);
+  initializeUnreachableBlockElimPass(*Registry);
+
+  // Register the target printer for --version.
+  cl::AddExtraVersionPrinter(TargetRegistry::printRegisteredTargetsForVersion);
+
+  cl::ParseCommandLineOptions(argc, argv, "llvm system compiler\n");
+
+  // Load the module to be compiled...
+  SMDiagnostic Err;
+  std::auto_ptr<Module> M;
+  Module *mod = 0;
+  Triple TheTriple;
+
+  M.reset(ParseIRFile(InputFilename, Err, Context));
+  mod = M.get();
+  if (mod == 0) {
+    Err.print(argv[0], errs());
+    return 1;
+  }
+
+  // If we are supposed to override the target triple, do so now.
+  if (!TargetTriple.empty())
+    mod->setTargetTriple(Triple::normalize(TargetTriple));
+  TheTriple = Triple(mod->getTargetTriple());
+
+  if (TheTriple.getTriple().empty())
+    TheTriple.setTriple(sys::getDefaultTargetTriple());
+
+  // Get the target specific parser.
+  std::string Error;
+  const Target *TheTarget = TargetRegistry::lookupTarget("bpf", TheTriple,
+                                                         Error);
+  if (!TheTarget) {
+    errs() << argv[0] << ": " << Error;
+    return 1;
+  }
+
+  // Package up features to be passed to target/subtarget
+  std::string FeaturesStr;
+  if (MAttrs.size()) {
+    SubtargetFeatures Features;
+    for (unsigned i = 0; i != MAttrs.size(); ++i)
+      Features.AddFeature(MAttrs[i]);
+    FeaturesStr = Features.getString();
+  }
+
+  CodeGenOpt::Level OLvl = CodeGenOpt::Default;
+  switch (OptLevel) {
+  default:
+    errs() << argv[0] << ": invalid optimization level.\n";
+    return 1;
+  case ' ': break;
+  case '0': OLvl = CodeGenOpt::None; break;
+  case '1': OLvl = CodeGenOpt::Less; break;
+  case '2': OLvl = CodeGenOpt::Default; break;
+  case '3': OLvl = CodeGenOpt::Aggressive; break;
+  }
+
+  TargetOptions Options;
+  Options.NoZerosInBSS = DontPlaceZerosInBSS;
+  Options.GuaranteedTailCallOpt = EnableGuaranteedTailCallOpt;
+  Options.DisableTailCalls = DisableTailCalls;
+
+  std::auto_ptr<TargetMachine>
+    target(TheTarget->createTargetMachine(TheTriple.getTriple(),
+                                          "", FeaturesStr, Options,
+                                          Reloc::Default, CodeModel::Default, OLvl));
+  assert(target.get() && "Could not allocate target machine!");
+  assert(mod && "Should have exited after outputting help!");
+  TargetMachine &Target = *target.get();
+
+  Target.setMCUseLoc(false);
+
+  Target.setMCUseCFI(false);
+
+  // Figure out where we are going to send the output.
+  OwningPtr<tool_output_file> Out
+    (GetOutputStream(TheTarget->getName(), TheTriple.getOS(), argv[0]));
+  if (!Out) return 1;
+
+  // Build up all of the passes that we want to do to the module.
+  PassManager PM;
+
+  // Add an appropriate TargetLibraryInfo pass for the module's triple.
+  TargetLibraryInfo *TLI = new TargetLibraryInfo(TheTriple);
+  if (DisableSimplifyLibCalls)
+    TLI->disableAllFunctions();
+  PM.add(TLI);
+
+  // Add the target data from the target machine, if it exists, or the module.
+  if (const DataLayout *TD = Target.getDataLayout())
+    PM.add(new DataLayout(*TD));
+  else
+    PM.add(new DataLayout(mod));
+
+  // Override default to generate verbose assembly.
+  Target.setAsmVerbosityDefault(true);
+
+  {
+    formatted_raw_ostream FOS(Out->os());
+
+    AnalysisID StartAfterID = 0;
+    AnalysisID StopAfterID = 0;
+    const PassRegistry *PR = PassRegistry::getPassRegistry();
+    if (!StartAfter.empty()) {
+      const PassInfo *PI = PR->getPassInfo(StartAfter);
+      if (!PI) {
+        errs() << argv[0] << ": start-after pass is not registered.\n";
+        return 1;
+      }
+      StartAfterID = PI->getTypeInfo();
+    }
+    if (!StopAfter.empty()) {
+      const PassInfo *PI = PR->getPassInfo(StopAfter);
+      if (!PI) {
+        errs() << argv[0] << ": stop-after pass is not registered.\n";
+        return 1;
+      }
+      StopAfterID = PI->getTypeInfo();
+    }
+
+    // Ask the target to add backend passes as necessary.
+    if (Target.addPassesToEmitFile(PM, FOS, FileType, NoVerify,
+                                   StartAfterID, StopAfterID)) {
+      errs() << argv[0] << ": target does not support generation of this"
+             << " file type!\n";
+      return 1;
+    }
+
+    // Before executing passes, print the final values of the LLVM options.
+    cl::PrintOptionValues();
+
+    PM.run(*mod);
+  }
+
+  // Declare success.
+  Out->keep();
+
+  return 0;
+}
-- 
1.7.9.5
